/**
 * ACT Bell — Main App Logic
 * Handles UI, interval timer, and Zoom Apps SDK initialization.
 */

document.addEventListener('DOMContentLoaded', () => {

  // --- Elements ---
  const bellBtn       = document.getElementById('bellBtn');
  const pitchSlider   = document.getElementById('pitchSlider');
  const pitchValue    = document.getElementById('pitchValue');
  const decaySlider   = document.getElementById('decaySlider');
  const decayValue    = document.getElementById('decayValue');
  const intervalSlider= document.getElementById('intervalSlider');
  const intervalValue = document.getElementById('intervalValue');
  const startBtn      = document.getElementById('startBtn');
  const stopBtn       = document.getElementById('stopBtn');
  const timerDisplay  = document.getElementById('timerDisplay');
  const timerValue    = document.getElementById('timerValue');
  const statusMsg     = document.getElementById('statusMsg');

  // --- State ---
  let intervalId   = null;
  let countdownId  = null;
  let secondsLeft  = 0;

  // --- Helpers ---
  function getPitch()    { return parseInt(pitchSlider.value, 10); }
  function getDecay()    { return parseFloat(decaySlider.value); }
  function getInterval() { return parseInt(intervalSlider.value, 10); }

  function formatSeconds(s) {
    if (s >= 60) {
      const m = Math.floor(s / 60);
      const rem = s % 60;
      return rem > 0 ? `${m} мин ${rem} с` : `${m} мин`;
    }
    return `${s} с`;
  }

  function setStatus(msg, type = 'info') {
    statusMsg.textContent = msg;
    statusMsg.className = `status-${type}`;
  }

  // --- Slider updates ---
  pitchSlider.addEventListener('input', () => {
    pitchValue.textContent = `${pitchSlider.value} Гц`;
  });

  decaySlider.addEventListener('input', () => {
    decayValue.textContent = `${parseFloat(decaySlider.value).toFixed(1)} с`;
  });

  intervalSlider.addEventListener('input', () => {
    intervalValue.textContent = formatSeconds(getInterval());
    if (intervalId) {
      // Restart interval with new value
      restartInterval();
    }
  });

  // --- Bell button ---
  bellBtn.addEventListener('click', () => {
    AudioEngine.playBell(getPitch(), getDecay());
    animateBell();
    setStatus('Сигнал воспроизведён', 'success');
  });

  function animateBell() {
    bellBtn.classList.add('ringing');
    setTimeout(() => bellBtn.classList.remove('ringing'), 600);
  }

  // --- Interval mode ---
  function startInterval() {
    const secs = getInterval();
    secondsLeft = secs;

    timerDisplay.hidden = false;
    startBtn.disabled = true;
    stopBtn.disabled = false;
    setStatus(`Интервал: ${formatSeconds(secs)}`, 'active');

    // Tick each second for countdown
    countdownId = setInterval(() => {
      secondsLeft--;
      timerValue.textContent = formatSeconds(secondsLeft);
      if (secondsLeft <= 0) {
        AudioEngine.playBell(getPitch(), getDecay());
        animateBell();
        secondsLeft = getInterval();
      }
    }, 1000);

    timerValue.textContent = formatSeconds(secondsLeft);
  }

  function stopInterval() {
    clearInterval(countdownId);
    countdownId = null;
    intervalId = null;
    startBtn.disabled = false;
    stopBtn.disabled = true;
    timerDisplay.hidden = true;
    setStatus('Остановлено');
  }

  function restartInterval() {
    clearInterval(countdownId);
    secondsLeft = getInterval();
    timerValue.textContent = formatSeconds(secondsLeft);
    countdownId = setInterval(() => {
      secondsLeft--;
      timerValue.textContent = formatSeconds(secondsLeft);
      if (secondsLeft <= 0) {
        AudioEngine.playBell(getPitch(), getDecay());
        animateBell();
        secondsLeft = getInterval();
      }
    }, 1000);
    setStatus(`Интервал обновлён: ${formatSeconds(getInterval())}`, 'active');
  }

  startBtn.addEventListener('click', startInterval);
  stopBtn.addEventListener('click', stopInterval);

  // --- Zoom Apps SDK init ---
  if (typeof zoomSdk !== 'undefined') {
    zoomSdk.config({
      popoutSize: { width: 360, height: 620 },
      capabilities: ['shareApp'],
    }).then(() => {
      setStatus('Zoom подключён', 'success');
    }).catch(err => {
      setStatus('Zoom SDK: ' + err.message, 'error');
    });
  } else {
    // Running outside of Zoom (dev/browser preview)
    setStatus('Предпросмотр (вне Zoom)');
  }

});
