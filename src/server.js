require('dotenv').config();
const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.static(path.join(__dirname, '../public')));
app.use(express.json());

// Landing page
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/index.html'));
});

// Bell tool (Zoom App)
app.get('/app/bell', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/app/bell.html'));
});

// Auth placeholders (будут реализованы с Supabase)
app.get('/login', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/index.html'));
});
app.get('/register', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/index.html'));
});

// Zoom Apps OAuth
app.get('/auth', (req, res) => {
  const { code } = req.query;
  if (!code) return res.status(400).json({ error: 'Missing authorization code' });
  res.redirect('/');
});

app.listen(PORT, () => {
  console.log(`ACT Tools running on http://localhost:${PORT}`);
});
