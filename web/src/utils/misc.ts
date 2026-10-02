// nb-dispatch - misc helpers
// Created by NullBound - Veyx (AJ)

export const isEnvBrowser = (): boolean => !(window as any).invokeNative;

export const noop = () => {};

export function formatClock(unixSeconds: number): string {
  const d = new Date(unixSeconds * 1000);
  return d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
}

export function timeAgo(unixSeconds: number): string {
  const diff = Math.max(0, Math.floor(Date.now() / 1000) - unixSeconds);
  if (diff < 60) return `${diff}s ago`;
  if (diff < 3600) return `${Math.floor(diff / 60)}m ago`;
  return `${Math.floor(diff / 3600)}h ago`;
}

export function countdown(expiresAtSeconds: number): string {
  const diff = Math.max(0, expiresAtSeconds - Math.floor(Date.now() / 1000));
  const m = Math.floor(diff / 60)
    .toString()
    .padStart(2, '0');
  const s = (diff % 60).toString().padStart(2, '0');
  return `${m}:${s}`;
}

export const priorityColor = (priority: number): string => {
  switch (priority) {
    case 1:
      return 'red';
    case 2:
      return 'orange';
    case 3:
      return 'blue';
    default:
      return 'gray';
  }
};

export const priorityLabel = (priority: number): string => {
  switch (priority) {
    case 1:
      return 'PRIORITY 1';
    case 2:
      return 'PRIORITY 2';
    case 3:
      return 'PRIORITY 3';
    default:
      return 'PRIORITY 4';
  }
};

export const statusColor = (color: string): string => {
  const map: Record<string, string> = {
    green: '#2f9e44',
    yellow: '#f08c00',
    blue: '#1c7ed6',
    orange: '#e8590c',
    grape: '#9c36b5',
    gray: '#5c5f66',
  };
  return map[color] || '#5c5f66';
};

export function copyToClipboard(text: string) {
  try {
    navigator.clipboard.writeText(text);
  } catch {
    const el = document.createElement('textarea');
    el.value = text;
    document.body.appendChild(el);
    el.select();
    document.execCommand('copy');
    document.body.removeChild(el);
  }
}
