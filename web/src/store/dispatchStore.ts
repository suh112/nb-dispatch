import { create } from 'zustand';
import type {
  DispatchCall,
  DispatchUnit,
  DispatchNotification,
  SyncMeta,
  PanicEvent,
  UnitDownEvent,
} from '../types/dispatch';

interface DispatchState {
  open: boolean;
  authorized: boolean;
  meta: SyncMeta | null;

  calls: DispatchCall[];
  units: DispatchUnit[];
  notifications: DispatchNotification[];

  selectedCallId: string | null;
  activeTab: 'dashboard' | 'calls' | 'units';
  panic: PanicEvent | null;
  unitDown: UnitDownEvent | null;
  newCallOpen: boolean;

  setOpen: (open: boolean) => void;
  setMeta: (meta: SyncMeta) => void;
  setCalls: (calls: DispatchCall[]) => void;
  setUnits: (units: DispatchUnit[]) => void;
  upsertNewCall: (call: DispatchCall) => void;
  selectCall: (id: string | null) => void;
  setActiveTab: (tab: 'dashboard' | 'calls' | 'units') => void;
  pushNotification: (n: Omit<DispatchNotification, 'id' | 'createdAt'>) => void;
  dismissNotification: (id: string) => void;
  setPanic: (p: PanicEvent | null) => void;
  setUnitDown: (u: UnitDownEvent | null) => void;
  setNewCallOpen: (v: boolean) => void;
}

export const useDispatchStore = create<DispatchState>((set, get) => ({
  open: false,
  authorized: false,
  meta: null,

  calls: [],
  units: [],
  notifications: [],

  selectedCallId: null,
  activeTab: 'dashboard',
  panic: null,
  unitDown: null,
  newCallOpen: false,

  setOpen: (open) => set({ open }),
  setMeta: (meta) => set({ meta, authorized: meta.authorized }),
  setCalls: (calls) => {
    const sorted = [...calls].sort((a, b) => {
      if (a.priority !== b.priority) return a.priority - b.priority;
      return a.createdAt - b.createdAt;
    });
    set({ calls: sorted });
    const selected = get().selectedCallId;
    if (selected && !sorted.find((c) => c.id === selected)) {
      set({ selectedCallId: null });
    }
  },
  setUnits: (units) => set({ units: [...units].sort((a, b) => a.callsign.localeCompare(b.callsign)) }),
  upsertNewCall: (call) =>
    set((state) => ({
      calls: [call, ...state.calls.filter((c) => c.id !== call.id)],
    })),
  selectCall: (id) => set({ selectedCallId: id }),
  setActiveTab: (tab) => set({ activeTab: tab }),
  pushNotification: (n) =>
    set((state) => ({
      notifications: [
        ...state.notifications,
        { ...n, id: `${Date.now()}-${Math.random()}`, createdAt: Date.now() },
      ],
    })),
  dismissNotification: (id) =>
    set((state) => ({ notifications: state.notifications.filter((n) => n.id !== id) })),
  setPanic: (p) => set({ panic: p }),
  setUnitDown: (u) => set({ unitDown: u }),
  setNewCallOpen: (v) => set({ newCallOpen: v }),
}));
