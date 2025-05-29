import os
import json
import asyncio
import logging
import traceback
from typing import List, Dict, Any
from concurrent.futures import ThreadPoolExecutor
import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import uvicorn

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class MessageRequest(BaseModel):
    message: str
    message_id: str = None


class BatchMessageRequest(BaseModel):
    messages: List[MessageRequest]


class PredictionResponse(BaseModel):
    message_id: str = None
    message: str
    is_bullying: bool
    confidence: float
    label: str


class BatchPredictionResponse(BaseModel):
    predictions: List[PredictionResponse]


class BullyingClassifier:
    def __init__(self, model_path: str = "greek_bert_cyberbullying", max_length: int = 256, batch_size: int = 8):
        self.model_path = model_path
        self.max_length = max_length
        self.batch_size = int(os.getenv("BATCH_SIZE", batch_size))
        self.device = self._set_device()
        self.model = None
        self.tokenizer = None
        self.load_model()

    def _set_device(self):
        if not torch.cuda.is_available():
            logger.warning(
                "CUDA NOT AVAILABLE !!!!!!!!!!!!!! USING CPU !!!!!!!!!! ")
            return torch.device("cpu")

        device_id = int(os.getenv("CUDA_VISIBLE_DEVICES", "0"))
        if device_id >= torch.cuda.device_count():
            logger.warning(
                f"CUDA device {device_id} not available, using device 0")
            device_id = 0

        device = torch.device(f"cuda:{device_id}")

        torch.cuda.set_per_process_memory_fraction(
            0.8, device_id)  # Use 80% of GPU memory

        return device

    def load_model(self):
        try:
            logger.info(f"Loading model from {self.model_path}")
            self.tokenizer = AutoTokenizer.from_pretrained(self.model_path)
            self.model = AutoModelForSequenceClassification.from_pretrained(
                self.model_path,
                torch_dtype=torch.float16 if self.device.type == "cuda" else torch.float32,
            )

            if self.device.type == "cuda":
                self.model = self.model.to(self.device)
                #self.model = torch.compile(self.model, mode="reduce-overhead")

            self.model.eval()

            self._warmup_model()

            logger.info(f"Model loaded successfully on {self.device}")

        except Exception as e:
            logger.error(f"Error loading model: {e}")
            raise e

    def _warmup_model(self):
        try:
            dummy = 'This is an example to warm up the model'
            dummy_input = self.tokenizer(dummy,
                             truncation=True,
                             padding=True,
                             max_length=self.max_length,
                             return_tensors="pt")

            # move to cuda
            dummy_input = {key: value.to(self.device)
                           for key, value in dummy_input.items()}

            with torch.no_grad():
                _ = self.model(**dummy_input)

            if self.device.type == "cuda":
                torch.cuda.synchronize()  # Wait for GPU operations to complete

            logger.info("Model warmup completed")
        except Exception as e:
            logger.warning(f"Model warmup failed: {e}")

    def preprocess_batch(self, texts: List[str]) -> Dict[str, torch.Tensor]:
        """Tokenize and prepare batch of texts for model input"""
        encoding = self.tokenizer(
            texts,
            truncation=True,
            padding=True,
            max_length=self.max_length,
            return_tensors="pt"
        )
        return {key: value.to(self.device) for key, value in encoding.items()}

    def predict_single(self, text: str) -> Dict[str, Any]:
        """Predict cyberbullying for a single message"""
        return self.predict_batch([text])[0]

    def predict_batch(self, texts: List[str]) -> List[Dict[str, Any]]:
        try:
            all_results = []

            for i in range(0, len(texts), self.batch_size):
                # get texts from i tll i+batch size
                batch_texts = texts[i:i + self.batch_size]
                batch_results = self._process_batch(batch_texts)
                all_results.extend(batch_results)

            return all_results

        except Exception as e:
            logger.error(f"Error in batch prediction: {e}")
            raise e

    def _process_batch(self, texts: List[str]) -> List[Dict[str, Any]]:
        try:
            inputs = self.preprocess_batch(texts)
            with torch.no_grad():
                if self.device.type == "cuda":
                    with torch.cuda.amp.autocast():
                        outputs = self.model(**inputs)
                else:
                    outputs = self.model(**inputs)

                probabilities = torch.nn.functional.softmax(
                    outputs.logits, dim=-1)
                predictions = torch.argmax(probabilities, dim=-1)
                confidences = torch.max(probabilities, dim=-1).values

            final_predictions = predictions.cpu().numpy()
            final_confidences = confidences.cpu().numpy()

            results = []
            for i in range(len(texts)):
                is_bullying = bool(final_predictions[i])
                confidence = float(final_confidences[i])
                label = "bullying" if is_bullying else "not_bullying"

                results.append({
                    "is_bullying": is_bullying,
                    "confidence": confidence,
                    "label": label
                })

            return results

        except Exception as e:
            logger.error(f"Error processing batch chunk: {e}")
            logger.error(traceback.format_exc()) 
            raise e


logger.info("Initializing BERT classifier...")
classifier = BullyingClassifier()

# Initialize FastAPI app
app = FastAPI(
    title="Cyberbullying Detection Service",
    description="BERT-based cyberbullying detection with CUDA acceleration",
    version="2.0.0"
)

# Reduced thread pool for GPU workloads (GPU handles parallelism internally)
executor = ThreadPoolExecutor(max_workers=int(os.getenv("MAX_WORKERS", "4")))


@app.get("/gpu/memory")
async def gpu_memory_stats():
    """Get current GPU memory usage"""
    if not torch.cuda.is_available() or classifier.device.type != "cuda":
        return {"error": "GPU not available"}

    device_id = classifier.device.index
    return {
        "device": f"cuda:{device_id}",
        "memory_allocated": f"{torch.cuda.memory_allocated(device_id) / 1e9:.2f}GB",
        "memory_reserved": f"{torch.cuda.memory_reserved(device_id) / 1e9:.2f}GB",
        "max_memory_allocated": f"{torch.cuda.max_memory_allocated(device_id) / 1e9:.2f}GB",
        "max_memory_reserved": f"{torch.cuda.max_memory_reserved(device_id) / 1e9:.2f}GB"
    }


@app.post("/predict", response_model=PredictionResponse)
async def predict_message(request: MessageRequest):
    """Predict cyberbullying for a single message"""
    try:
        loop = asyncio.get_event_loop()
        result = await loop.run_in_executor(
            executor,
            classifier.predict_single,
            request.message
        )

        return PredictionResponse(
            message_id=request.message_id,
            message=request.message,
            **result
        )
    except Exception as e:
        logger.error(f"Error processing single prediction: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/predict/batch", response_model=BatchPredictionResponse)
async def predict_batch_messages(request: BatchMessageRequest):
    """Predict cyberbullying for multiple messages with GPU optimization"""
    try:
        messages = [msg.message for msg in request.messages]

        loop = asyncio.get_event_loop()
        results = await loop.run_in_executor(
            executor,
            classifier.predict_batch,
            messages
        )

        predictions = []
        for i, (msg_request, result) in enumerate(zip(request.messages, results)):
            predictions.append(PredictionResponse(
                message_id=msg_request.message_id,
                message=msg_request.message,
                **result
            ))

        return BatchPredictionResponse(predictions=predictions)
    except Exception as e:
        logger.error(f"Error processing batch prediction: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    port = int(os.getenv("PORT", "8000"))
    host = os.getenv("HOST", "0.0.0.0")

    uvicorn.run(
        app,
        host=host,
        port=port,
        workers=1
    )
