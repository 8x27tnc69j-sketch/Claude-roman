# ACT Bell — Zoom App

Минималистичный инструмент для терапевтов, работающих в подходе ACT (Acceptance and Commitment Therapy). Запускается в сайдбаре Zoom во время сессии.

## Возможности

- **Кнопка звонка** — одиночный медитативный звук по нажатию
- **Высота тона** — регулировка от 200 до 900 Гц
- **Длительность звука** — от 0.5 до 6 секунд
- **Интервальный режим** — автоматические сигналы с заданным интервалом (10 с — 10 мин)
- **Обратный отсчёт** — показывает время до следующего сигнала

## Технологии

- **Web Audio API** — синтез звука (звонок/поющая чаша), без аудиофайлов
- **Zoom Apps SDK** — встраивание в сайдбар видеозвонка
- **Express** — сервер для хостинга

## Запуск (разработка)

```bash
npm install
cp .env.example .env
# Заполните .env своими Zoom App credentials
npm run dev
```

Откройте http://localhost:3000 для предпросмотра вне Zoom.

## Публикация в Zoom Marketplace

1. Зайдите на [marketplace.zoom.us](https://marketplace.zoom.us) → Build App → Zoom Apps
2. Укажите Home URL: `https://your-domain/`
3. Скопируйте Client ID / Secret в `.env`
4. Задеплойте сервер (Render, Railway, Vercel и т.д.)

## Структура проекта

```
├── public/
│   ├── index.html        # UI
│   ├── css/style.css     # Стили (тёмная тема)
│   └── js/
│       ├── audio.js      # Синтез звука (Web Audio API)
│       └── app.js        # Логика UI + таймер + Zoom SDK
└── src/
    └── server.js         # Express сервер
```
