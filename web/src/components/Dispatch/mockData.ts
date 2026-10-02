// Browser-preview mock data (only used when running `npm start`, never in game)
import type { DispatchCall, DispatchUnit, SyncMeta } from '../../types/dispatch';

export const MOCK_META: SyncMeta = {
  authorized: true,
  permissionLevel: 2,
  permissionName: 'dispatcher',
  officer: {
    id: 1,
    callsign: 'NB-1',
    name: 'J. Veyx',
    job: 'police',
    jobLabel: 'Police',
    department: 'police',
    grade: 3,
    gradeLabel: 'Lieutenant',
    status: 'available',
    currentCall: null,
    coords: { x: 441.9, y: -981.3, z: 30.7 },
    lastUpdate: Math.floor(Date.now() / 1000),
  },
  statuses: [
    { id: 'available', label: 'Available', color: 'green', selectable: true },
    { id: 'enroute', label: 'En Route', color: 'yellow', selectable: true },
    { id: 'onscene', label: 'On Scene', color: 'blue', selectable: true },
    { id: 'busy', label: 'Busy', color: 'orange', selectable: true },
    { id: 'transporting', label: 'Transporting', color: 'grape', selectable: true },
    { id: 'unavailable', label: 'Unavailable', color: 'gray', selectable: true },
  ],
};

const now = Math.floor(Date.now() / 1000);

export const MOCK_CALLS: DispatchCall[] = [
  {
    id: 'C-10231',
    code: '10-31',
    title: 'Store Robbery',
    description: '24/7 store robbery in progress, suspect armed.',
    priority: 1,
    coords: { x: 25.7, y: -1347.3, z: 29.5 },
    postal: '1482',
    street: 'Vespucci Blvd',
    caller: 'Store Clerk',
    callerPhone: '555-0123',
    createdAt: now - 45,
    expiresAt: now + 555,
    status: 'pending',
    assignedUnits: [],
    notes: [],
    jobs: ['police', 'sheriff'],
    source: 'player',
  },
  {
    id: 'C-10445',
    code: '10-50',
    title: 'Vehicle Accident',
    description: 'Two car collision, possible injuries.',
    priority: 2,
    coords: { x: -1035.9, y: -2742.1, z: 20.2 },
    postal: '2210',
    street: 'Elgin Ave',
    caller: 'Bystander',
    callerPhone: '555-0456',
    createdAt: now - 180,
    expiresAt: now + 420,
    status: 'active',
    assignedUnits: [{ id: 2, callsign: 'NB-2', name: 'S. Carter', job: 'police' }],
    notes: [{ id: 'N-1', author: 'NB-2', authorSource: 2, message: 'On scene, light damage.', createdAt: now - 60 }],
    jobs: ['police', 'sheriff', 'state'],
    source: 'automatic',
  },
];

export const MOCK_UNITS: DispatchUnit[] = [
  {
    id: 1, callsign: 'NB-1', name: 'J. Veyx', job: 'police', jobLabel: 'Police',
    department: 'police', grade: 3, gradeLabel: 'Lieutenant', status: 'available',
    currentCall: null, coords: { x: 441.9, y: -981.3, z: 30.7 }, lastUpdate: now,
  },
  {
    id: 2, callsign: 'NB-2', name: 'S. Carter', job: 'police', jobLabel: 'Police',
    department: 'police', grade: 1, gradeLabel: 'Senior Officer', status: 'onscene',
    currentCall: 'C-10445', coords: { x: -1035.9, y: -2742.1, z: 20.2 }, lastUpdate: now,
  },
  {
    id: 3, callsign: 'SO-4', name: 'K. Ibanez', job: 'sheriff', jobLabel: 'Sheriff',
    department: 'police', grade: 0, gradeLabel: 'Grade 0', status: 'busy',
    currentCall: null, coords: { x: 1849.1, y: 3689.7, z: 34.2 }, lastUpdate: now,
  },
];
