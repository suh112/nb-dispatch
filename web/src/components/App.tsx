import { useEffect } from 'react';
import { Box } from '@mantine/core';
import { useNuiEvent } from '../hooks/useNuiEvent';
import { useDispatchStore } from '../store/dispatchStore';
import { fetchNui } from '../utils/fetchNui';
import { isEnvBrowser } from '../utils/misc';
import type {
  DispatchCall,
  DispatchUnit,
  SyncMeta,
  PanicEvent,
} from '../types/dispatch';
import Shell from './Dispatch/Shell';
import PanicOverlay from './Dispatch/PanicOverlay';
import NotificationStack from './Dispatch/NotificationStack';
import { MOCK_META, MOCK_CALLS, MOCK_UNITS } from './Dispatch/mockData';

export default function App() {
  const setOpen = useDispatchStore((s) => s.setOpen);
  const setMeta = useDispatchStore((s) => s.setMeta);
  const setCalls = useDispatchStore((s) => s.setCalls);
  const setUnits = useDispatchStore((s) => s.setUnits);
  const upsertNewCall = useDispatchStore((s) => s.upsertNewCall);
  const pushNotification = useDispatchStore((s) => s.pushNotification);
  const setPanic = useDispatchStore((s) => s.setPanic);
  const open = useDispatchStore((s) => s.open);

  useNuiEvent<void>('dispatch:open', () => setOpen(true));
  useNuiEvent<void>('dispatch:close', () => setOpen(false));
  useNuiEvent<SyncMeta>('dispatch:syncMeta', (data) => setMeta(data));
  useNuiEvent<DispatchCall[]>('dispatch:updateCalls', (data) => setCalls(data));
  useNuiEvent<DispatchUnit[]>('dispatch:updateUnits', (data) => setUnits(data));
  useNuiEvent<DispatchCall>('dispatch:newCall', (data) => upsertNewCall(data));
  useNuiEvent<PanicEvent>('dispatch:panic', (data) => setPanic(data));
  useNuiEvent<{ message: string; type: 'success' | 'error' | 'info' }>(
    'dispatch:notify',
    (data) => pushNotification({ message: data.message, type: data.type }),
  );

  useEffect(() => {
    const escHandler = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && useDispatchStore.getState().open) {
        fetchNui('close');
        setOpen(false);
      }
    };
    window.addEventListener('keydown', escHandler);
    return () => window.removeEventListener('keydown', escHandler);
  }, [setOpen]);

  // Browser preview (npm start): seed mock state so the UI is visible
  useEffect(() => {
    if (!isEnvBrowser()) return;
    setMeta(MOCK_META);
    setCalls(MOCK_CALLS);
    setUnits(MOCK_UNITS);
    setOpen(true);
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  return (
    <Box style={{ width: '100vw', height: '100vh', position: 'relative' }}>
      {open && <Shell />}
      <PanicOverlay />
      <NotificationStack />
    </Box>
  );
}
