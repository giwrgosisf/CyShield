FROM pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY microservices/message_classifier/requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY microservices/message_classifier/app/greek_bert_inference.py .
COPY microservices/greek_bert_cyberbullying ./greek_bert_cyberbullying

# Create a non-root user for security
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Expose port
EXPOSE 9090

# Set environment variables
ENV PYTHONPATH=/app
ENV MAX_WORKERS=4
ENV BATCH_SIZE=32
ENV HOST=0.0.0.0
ENV PORT=9090
ENV CUDA_VISIBLE_DEVICES=0

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=120s --retries=3 \
    CMD curl -f http://localhost:9090/health || exit 1

# Run the application
CMD ["python", "greek_bert_inference.py"]