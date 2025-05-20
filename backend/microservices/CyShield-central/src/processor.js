require("dotenv").config();
const { Queue, Worker } = require("bullmq");
const IORedis = require("ioredis");
const os = require("os");
const axios = require("axios");
const { logNotification } = require("./firestoreService");
const { saveToxicMessage } = require("./firestoreService");
const { notifyParent } = require("./fcmService");
const { randomUUID } = require('crypto');


const connection = new IORedis({
  host: process.env.REDIS_HOST || "redis",
  port: process.env.REDIS_PORT || 6379,
  maxRetriesPerRequest: null,
});

function spawnProcessor(queueName) {
  const worker = new Worker(
    queueName,
    async (job) => {
      const { text, user_id } = job.data;

      // TODO: replace with your real ML call
      // const { data: { label } } = await axios.post(
      //   process.env.MODEL_API_URL,
      //   { text },
      // );
      const label = "toxic";

      if (label === "toxic") {
        //await saveToxicMessage(user_id, text);
        
        const id = randomUUID();
        await logNotification(user_id, {
          type: "new_report",
          body: `Toxic message detected: "${
            text.length > 50 ? text.slice(0, 47) + "…" : text
          }"`,
          metadata:{reportId: id},
        });

        await notifyParent(user_id, {
          title: "Toxic Message Detected",
          body: text.length > 100 ? text.slice(0, 97) + "…" : text,
          data: {
            type: "new_report",
            reportId: id,
          },
        });
      }
      return { label };
    },
    {
      connection,
      concurrency: os.cpus().length,
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
