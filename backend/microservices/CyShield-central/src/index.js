const cluster = require('cluster');
const os = require('os');
const path = require('path');

if (cluster.isPrimary) {
  console.log('===========================PARALLEL SYSTEM ACTVATION============================');
  const cpuCount = os.cpus().length;
  console.log('found %d CPUs', cpuCount, 'activating....');
  console.log(`The system will use 2 CPU cores for HTTP and 4 for processing.`);
  console.log('To find a relistic scenario, for your system please use the formula to avoid overforking');
  console.log('(processCount) × (queues per process) × (concurrency) <= your desired max');
  console.log('For example:');
  console.log('Example for 16-core machine:');
  console.log(`  processorProcesses = 4  (4 cores for processing)`);
  console.log(`  queues per process = 2  (telegramQueue + signalQueue)`);
  console.log('  desiredMaxInFlightJobs = 32');
  console.log('  → workerConcurrency = floor(32 / (4 × 2)) = 4');
  console.log('  Result: 4 processes × 2 queues × 4 concurrency = 32 in-flight jobs');
  console.log('==============================================================================');

 
  for (let i = 0; i < 2; i++) {
    cluster.fork({ ROLE: 'http' });
  }

  for (let i = 0; i < 4; i++) {
    cluster.fork({ ROLE: 'processor' });
  }

  cluster.on('exit', (worker, code, signal) => {
    console.warn(`Worker ${worker.process.pid} died; forking same role again.`);
    cluster.fork(worker.process.env);
  });
} else {
  
  if (process.env.ROLE === 'http') {
    
    const express = require('express');
    const bodyParser = require('body-parser');
    const router = require('./router');
    require('dotenv').config();

    const app = express();
    app.use(bodyParser.json());
    app.use('/message', router);

    const PORT = process.env.PORT || 8000;
    app.listen(PORT, () => {
      console.log(`HTTP worker ${process.pid} listening on ${PORT}`);
    });

  } else {
    
    require('./processor');
    console.log(`Processor worker ${process.pid} started`);
  }
}
