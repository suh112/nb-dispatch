import { isEnvBrowser } from './misc';

/**
 * Wrapper around fetch tailored for CEF/NUI. Falls through to mockData
 * when running in a regular browser (local dev with `npm start`).
 */
export async function fetchNui<T = unknown>(
  eventName: string,
  data?: unknown,
  mockData?: T,
): Promise<T> {
  const options = {
    method: 'post',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: JSON.stringify(data ?? {}),
  };

  if (isEnvBrowser()) {
    return (mockData as T) ?? (({ ok: true } as unknown) as T);
  }

  const resourceName = (window as any).GetParentResourceName
    ? (window as any).GetParentResourceName()
    : 'nb-dispatch';

  const resp = await fetch(`https://${resourceName}/${eventName}`, options);
  return resp.json();
}
