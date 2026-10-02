import { MutableRefObject, useEffect, useRef } from 'react';
import { noop } from '../utils/misc';
import type { NuiMessageData } from '../types/dispatch';

type NuiHandlerSignature<T> = (data: T) => void;

/**
 * Listens for SendNUIMessage({ action, data }) calls matching `action`.
 */
export const useNuiEvent = <T = unknown>(
  action: string,
  handler: (data: T) => void,
) => {
  const savedHandler: MutableRefObject<NuiHandlerSignature<T>> = useRef(noop);

  useEffect(() => {
    savedHandler.current = handler;
  }, [handler]);

  useEffect(() => {
    const listener = (event: MessageEvent<NuiMessageData<T>>) => {
      const { action: eventAction, data } = event.data;
      if (eventAction === action) {
        savedHandler.current(data);
      }
    };
    window.addEventListener('message', listener);
    return () => window.removeEventListener('message', listener);
  }, [action]);
};
