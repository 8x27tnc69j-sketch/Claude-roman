/**
 * ACT Bell — Audio Engine
 * Generates a singing bowl / meditation bell sound using Web Audio API.
 * No audio files needed — everything is synthesized in the browser.
 */

const AudioEngine = (() => {
  let ctx = null;

  function getContext() {
    if (!ctx) {
      ctx = new (window.AudioContext || window.webkitAudioContext)();
    }
    // Resume if suspended (browser autoplay policy)
    if (ctx.state === 'suspended') {
      ctx.resume();
    }
    return ctx;
  }

  /**
   * Play a meditation bell tone.
   * @param {number} frequency  - Fundamental frequency in Hz (default 432)
   * @param {number} decayTime  - Envelope decay in seconds (default 2)
   */
  function playBell(frequency = 432, decayTime = 2) {
    const context = getContext();
    const now = context.currentTime;

    // --- Fundamental tone ---
    const osc1 = context.createOscillator();
    const gain1 = context.createGain();
    osc1.type = 'sine';
    osc1.frequency.setValueAtTime(frequency, now);
    gain1.gain.setValueAtTime(0.6, now);
    gain1.gain.exponentialRampToValueAtTime(0.0001, now + decayTime);
    osc1.connect(gain1);

    // --- 2nd harmonic (octave) for bell shimmer ---
    const osc2 = context.createOscillator();
    const gain2 = context.createGain();
    osc2.type = 'sine';
    osc2.frequency.setValueAtTime(frequency * 2.756, now); // inharmonic partial
    gain2.gain.setValueAtTime(0.25, now);
    gain2.gain.exponentialRampToValueAtTime(0.0001, now + decayTime * 0.7);
    osc2.connect(gain2);

    // --- 3rd partial ---
    const osc3 = context.createOscillator();
    const gain3 = context.createGain();
    osc3.type = 'sine';
    osc3.frequency.setValueAtTime(frequency * 5.404, now);
    gain3.gain.setValueAtTime(0.08, now);
    gain3.gain.exponentialRampToValueAtTime(0.0001, now + decayTime * 0.4);
    osc3.connect(gain3);

    // --- Master gain with soft attack ---
    const master = context.createGain();
    master.gain.setValueAtTime(0, now);
    master.gain.linearRampToValueAtTime(1, now + 0.008); // 8ms attack

    gain1.connect(master);
    gain2.connect(master);
    gain3.connect(master);
    master.connect(context.destination);

    // Start & stop
    [osc1, osc2, osc3].forEach(o => {
      o.start(now);
      o.stop(now + decayTime + 0.1);
    });
  }

  return { playBell };
})();
