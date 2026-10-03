import illegalSound from '../assets/sounds/alert_illegal.mp3';
import panicSound from '../assets/sounds/alert_panic.mp3';
import unitDownSound from '../assets/sounds/alert_unitdown.mp3';
import newCallSound from '../assets/sounds/alert_newcall.mp3';

export type AlertSoundKey = 'illegal' | 'panic' | 'unitdown' | 'newcall';

const sources: Record<AlertSoundKey, string> = {
  illegal: illegalSound,
  panic: panicSound,
  unitdown: unitDownSound,
  newcall: newCallSound,
};

export function playAlertSound(key: AlertSoundKey, volume = 0.6) {
  try {
    const src = sources[key];
    if (!src) return;
    const audio = new Audio(src);
    audio.volume = Math.min(1, Math.max(0, volume));
    void audio.play().catch(() => {});
  } catch {
  }
}
