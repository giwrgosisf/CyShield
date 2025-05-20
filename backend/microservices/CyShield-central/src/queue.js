const {Queue} = require('bullmq');
const  IORedis = require('ioredis');


const connection = new IORedis({
  host: process.env.REDIS_HOST || 'redis',
  port: process.env.REDIS_PORT || 6379,
});


const telegramQueue = new Queue('telegramQueue', {connection});

const signalQueue = new Queue('signalQueue', {connection});

module.exports = {
  telegramQueue,
  signalQueue,
};