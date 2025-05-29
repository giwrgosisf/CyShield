require("dotenv").config();
const { Queue, Worker } = require("bullmq");
const IORedis = require("ioredis");
const os = require("os");
const axios = require("axios");
const {
  logNotification,
  raiseMessaCaounter,
  raiseToxicCaounter,
  raiseHealthyCaounter,
  raiseModerateCaounter,
} = require("./firestoreService");
const { saveToxicMessage } = require("./firestoreService");
const { notifyParent } = require("./fcmService");
const { randomUUID } = require("crypto");
const {
  findKidByPhoneNumber,
  findCoreSpondingParents,
} = require("./firestoreService");

const WORKER_CONCURRENCY = 4;

const ML_SERVICE_URL = "http://backend-ml-service-1:9090/predict"; // Replace with your actual ML service URL

const connection = new IORedis({
  host: process.env.REDIS_HOST || "redis",
  port: process.env.REDIS_PORT || 6379,
  maxRetriesPerRequest: null,
});

function spawnProcessor(queueName) {
  const worker = new Worker(
    queueName,
    async (job) => {
      const { text, user_id, sender } = job.data;
      let processedLabel = "unknown";

      const kidId = await findKidByPhoneNumber(user_id);

      try {
        const response = await axios.post(ML_SERVICE_URL, {
          message: text,
          message_id: randomUUID(),
        });

        const { label, confidence, is_bullying } = response.data;

        console.log(
          `Received prediction: label=${label}, confidence=${confidence}`
        );

        processedLabel = label;
        console.log(`Processed label: ${processedLabel} for text: "${text}"`);

        if (label === "bullying") {
          const id = randomUUID();

          if (!kidId) {
            console.error(`No kid found for user_id: ${user_id}`);
            return { label: processedLabel, score: response.score };
          }
          console.log("this text is =========>", text, "from sender:", sender);
          saveToxicMessage(kidId, text, confidence, sender);
          if (confidence > 0.8) {
            await raiseToxicCaounter(kidId);
          }else{
           await raiseModerateCaounter(kidId)
          }
          console.log(`Toxic message saved for kid ${kidId}:`, text);
          const parents = await findCoreSpondingParents(kidId);
          console.log(`Found parents for kid ${kidId}:`, parents);

          for (const parent of parents) {
            await logNotification(parent, {
              type: "new_report",
              body: `Toxic message detected: "${
                text.length > 50 ? text.slice(0, 47) + "…" : text
              }"`,
              metadata: { reportId: id },
            });

            await notifyParent(parent, {
              title: "Toxic Message Detected",
              body: text.length > 100 ? text.slice(0, 97) + "…" : text,
              data: {
                type: "new_report",
                reportId: id,
              },
            });
          }
        } else {
          raiseHealthyCaounter(kidId);
        }

        return { label: processedLabel };
      } catch (error) {
        // console.error("Processing error:", error);
        return { label: processedLabel };
      }
    },
    {
      connection,
      concurrency: WORKER_CONCURRENCY,
    }
  );
  worker.on("completed", (job) => {
    const { label } = job.returnvalue;
    console.log(
      `Job ${job.id} completed with label: ${label} for ${queueName}`
    );
  });

  worker.on("failed", (job, err) => {
    console.error(`Job ${job.id} failed with error: ${err.message}`);
  });

  console.log(`Processor for ${queueName} started (pid ${process.pid})`);
  return worker;
}

spawnProcessor("telegramQueue");
spawnProcessor("signalQueue");
