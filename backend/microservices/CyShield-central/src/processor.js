require("dotenv").config();
const { Queue, Worker } = require("bullmq");
const IORedis = require("ioredis");
const os = require("os");
const axios = require("axios");
const { logNotification } = require("./firestoreService");
const { saveToxicMessage } = require("./firestoreService");
const { notifyParent } = require("./fcmService");
const { randomUUID } = require('crypto');
const { findKidByPhoneNumber, findCoreSpondingParents } = require("./firestoreService");


const WORKER_CONCURRENCY = 4;

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
        

        const id = randomUUID();

        kidId = await findKidByPhoneNumber(user_id);
        if (!kidId) {
          console.error(`No kid found for user_id: ${user_id}`);
          return;
        }

        saveToxicMessage(kidId, text);
        console.log(`Toxic message saved for kid ${kidId}:`, text);
        const parents  = await findCoreSpondingParents(kidId);
        console.log(`Found parents for kid ${kidId}:`, parents);

        for (const parent of parents) {
          await logNotification(parent, {
            type: "new_report",
            body: `Toxic message detected: "${text.length > 50 ? text.slice(0, 47) + "…" : text
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
      }
      return { label };
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
