const cluster = require('cluster');
const os = require('os');
const path = require('path');

if (cluster.isPrimary) {

  const cpuCount = os.cpus().length;
  console.log('found %d CPUs', cpuCount, 'activating....');
  console.log(`Master ${process.pid} forking ${cpuCount * 2} workers`);

 
  for (let i = 0; i < 2; i++) {
    cluster.fork({ ROLE: 'http' });
  }

  for (let i = 0; i < cpuCount-2; i++) {
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
