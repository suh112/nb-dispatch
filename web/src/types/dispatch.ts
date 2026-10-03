export interface DispatchCoords {
  x: number;
  y: number;
  z: number;
}

export interface DispatchNote {
  id: string;
  author: string;
  authorSource: number;
  message: string;
  createdAt: number;
}

export interface DispatchAssignedUnit {
  id: number;
  callsign: string;
  name: string;
  job: string;
}

export interface DispatchBlip {
  sprite: number;
  color: number;
  scale: number;
  duration: number;
  flash?: boolean;
}

export type CallStatus = 'pending' | 'active' | 'closed';
export type CallSource = 'player' | 'automatic' | 'citizen' | 'resource' | 'panic' | 'unitdown';

export interface DispatchCall {
  id: string;
  code: string;
  title: string;
  description: string;
  priority: 1 | 2 | 3 | 4;
  coords: DispatchCoords;
  postal: string | null;
  street: string;
  caller: string;
  callerPhone: string;
  createdAt: number;
  expiresAt: number;
  status: CallStatus;
  assignedUnits: DispatchAssignedUnit[];
  notes: DispatchNote[];
  blip?: DispatchBlip;
  jobs: string[];
  department?: string;
  source?: CallSource;
  closedAt?: number;
  closedBy?: string;
}

export type UnitStatusId =
  | 'available'
  | 'enroute'
  | 'onscene'
  | 'busy'
  | 'transporting'
  | 'unavailable';

export interface DispatchUnitStatusDef {
  id: UnitStatusId;
  label: string;
  color: string;
  selectable: boolean;
}

export interface DispatchUnit {
  id: number;
  callsign: string;
  name: string;
  job: string;
  jobLabel: string;
  department: string;
  grade: number;
  gradeLabel: string;
  status: UnitStatusId;
  currentCall: string | null;
  coords: DispatchCoords;
  lastUpdate: number;
}

export interface DispatchOfficer extends DispatchUnit {}

export interface DispatchJobConfig {
  enabled: boolean;
  label: string;
  type?: string;
  grades?: Record<number, string>;
}

export interface DispatchCallTypeConfig {
  code: string;
  title: string;
  priority: 1 | 2 | 3 | 4;
  jobs?: string[];
  blip?: DispatchBlip;
}

export interface DispatchSettings {
  soundsEnabled: boolean;
  compactMode: boolean;
}

export type NotificationType = 'success' | 'error' | 'info';

export interface DispatchNotification {
  id: string;
  message: string;
  type: NotificationType;
  createdAt: number;
}

export interface SyncMeta {
  authorized: boolean;
  permissionLevel?: number;
  permissionName?: string;
  officer?: DispatchOfficer;
  jobs?: Record<string, DispatchJobConfig>;
  statuses?: DispatchUnitStatusDef[];
  callTypes?: Record<string, DispatchCallTypeConfig>;
  actionPermissions?: Record<string, string>;
}

export interface PanicEvent {
  source: number;
  callsign: string;
  name: string;
  department: string;
  coords: DispatchCoords;
  callId?: string;
}

export interface UnitDownEvent {
  source: number;
  callsign: string;
  name: string;
  department: string;
  coords: DispatchCoords;
  callId?: string;
}

export interface NuiMessageData<T = unknown> {
  action: string;
  data: T;
}
