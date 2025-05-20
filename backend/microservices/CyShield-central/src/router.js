const express = require('express');
const { telegramQueue, signalQueue } = require('./queue');  
const IORedis = require('ioredis');

const router = express.Router();





router.post('/', async (req, res) => {
  console.log('Received request:', req.body, 'in central');
  const { user_id, message: { date, platform,text, from: { username: sender }, to: { username: receiver } } } = req.body;
  

  if (!text || !user_id) {
    console.error('Missing content or user_id');
    return res.status(400).json({ error: 'Missing content or user_id' });
  }else {
    console.log('Received message:', text, 'from user:', user_id , 'on platform:', platform);
  }

  try {
    console.log('Enqueuing message for classification:', text,'from user', user_id, 'on platform:', platform);
    
    
    if (platform === 'Telegram') {
      await telegramQueue.add('classify', { text, user_id });
    }
    else if (platform === 'signal') {
      await signalQueue.add('classify', { text, user_id });
    } else {
      console.error('Unsupported platform:', platform);
      return res.status(400).json({ error: 'Unsupported platform' });
    }
    res.status(202).json({ status: 'queued' });
    console.log('Message enqueued successfully');
  } catch (err) {
    console.error('Error adding job to queue:', err);
    res.status(500).json({ error: 'Failed to enqueue message' });
  }
});

module.exports = router;