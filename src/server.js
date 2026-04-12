require('dotenv').config();
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const path = require('path');

const app = express();
const httpServer = http.createServer(app);
const io = new Server(httpServer);
const PORT = process.env.PORT || 3000;

// Security headers required by Zoom App Marketplace
app.use((req, res, next) => {
  res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  res.setHeader('Content-Security-Policy',
    "default-src 'self'; " +
    "script-src 'self' 'unsafe-inline' https://appssdk.zoom.us https://*.zoom.us; " +
    "style-src 'self' 'unsafe-inline'; " +
    "img-src 'self' data: https:; " +
    "connect-src 'self' wss: ws: https:; " +
    "font-src 'self' https:;"
  );
  next();
});

app.use(express.static(path.join(__dirname, '../public')));
app.use(express.json());

// Routes
app.get('/', (req, res) => res.sendFile(path.join(__dirname, '../public/index.html')));
app.get('/app', (req, res) => res.sendFile(path.join(__dirname, '../public/app/index.html')));
app.get('/app/bell', (req, res) => res.sendFile(path.join(__dirname, '../public/app/bell.html')));
app.get('/app/rope', (req, res) => res.sendFile(path.join(__dirname, '../public/app/rope-client.html')));
app.get('/app/rope-therapist', (req, res) => res.sendFile(path.join(__dirname, '../public/app/rope-therapist.html')));
app.get('/app/values', (req, res) => res.sendFile(path.join(__dirname, '../public/app/values.html')));

// API: проверить есть ли активный сеанс канатного упражнения (для Zoom auto-routing)
app.get('/api/session/:roomCode', (req, res) => {
  const session = sessions.get(req.params.roomCode);
  res.json({ active: !!(session && session.therapistId) });
});
app.get('/login', (req, res) => res.sendFile(path.join(__dirname, '../public/index.html')));
app.get('/register', (req, res) => res.sendFile(path.join(__dirname, '../public/index.html')));
app.get('/auth', (req, res) => {
  const { code } = req.query;
  if (!code) return res.status(400).json({ error: 'Missing authorization code' });
  res.redirect('/');
});

// WebSocket — rope sessions
const sessions = new Map(); // roomCode -> { therapistId, clientId }

io.on('connection', (socket) => {

  socket.on('therapist-create', (roomCode) => {
    sessions.set(roomCode, { therapistId: socket.id, clientId: null });
    socket.join(roomCode);
  });

  socket.on('client-join', (roomCode) => {
    const session = sessions.get(roomCode);
    if (session) {
      session.clientId = socket.id;
      socket.join(roomCode);
      socket.to(roomCode).emit('client-connected');
    }
  });

  socket.on('exercise-start', (roomCode) => {
    socket.to(roomCode).emit('exercise-start');
  });

  socket.on('exercise-stop', (roomCode) => {
    socket.to(roomCode).emit('exercise-stop');
  });

  socket.on('therapist-force', ({ roomCode, fx, fy }) => {
    socket.to(roomCode).emit('therapist-force', { fx, fy });
  });

  socket.on('monster-release', (roomCode) => {
    socket.to(roomCode).emit('monster-release');
  });

  socket.on('therapist-release', (roomCode) => {
    socket.to(roomCode).emit('monster-release');
  });

  socket.on('client-holding', ({ roomCode, holding }) => {
    socket.to(roomCode).emit('client-holding-update', holding);
  });

  socket.on('ball-position', ({ roomCode, nx, ny }) => {
    socket.to(roomCode).emit('ball-position-update', { nx, ny });
  });

  socket.on('disconnect', () => {
    for (const [code, session] of sessions.entries()) {
      if (session.therapistId === socket.id || session.clientId === socket.id) {
        socket.to(code).emit('peer-disconnected');
        sessions.delete(code);
      }
    }
  });
});

httpServer.listen(PORT, () => {
  console.log(`ACT Tools running on http://localhost:${PORT}`);
});
