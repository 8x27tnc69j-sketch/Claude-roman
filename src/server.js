require('dotenv').config();
const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.static(path.join(__dirname, '../public')));
app.use(express.json());

// Zoom Apps SDK auth flow
app.get('/auth', (req, res) => {
  const { code } = req.query;
  if (!code) {
    return res.status(400).json({ error: 'Missing authorization code' });
  }
  // In production: exchange code for access token via Zoom OAuth
  res.redirect('/');
});

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/index.html'));
});

app.listen(PORT, () => {
  console.log(`ACT Therapy Zoom App running on http://localhost:${PORT}`);
});
