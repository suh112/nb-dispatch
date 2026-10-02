import { useState } from 'react';
import {
  alpha, Box, Group, Stack, Text, Badge, Button, ActionIcon, Textarea, Divider, ScrollArea, useMantineTheme,
} from '@mantine/core';
import {
  ArrowLeft, MapPin, Phone, Clock, Copy, Navigation, MapPinOff, CheckCircle2,
  UserPlus, UserMinus, XCircle, Send,
} from 'lucide-react';
import { useDispatchStore } from '../../store/dispatchStore';
import { fetchNui } from '../../utils/fetchNui';
import { copyToClipboard, priorityColor, priorityLabel, formatClock } from '../../utils/misc';

export default function CallDetail() {
  const theme = useMantineTheme();
  const selectedCallId = useDispatchStore((s) => s.selectedCallId);
  const calls = useDispatchStore((s) => s.calls);
  const selectCall = useDispatchStore((s) => s.selectCall);
  const officer = useDispatchStore((s) => s.meta?.officer);
  const [note, setNote] = useState('');

  const call = calls.find((c) => c.id === selectedCallId);
  if (!call) return null;

  const pColor = priorityColor(call.priority);
  const isAssignedToMe = officer ? call.assignedUnits.some((u) => u.id === officer.id) : false;

  const accept = () => fetchNui('acceptCall', { callId: call.id });
  const assignSelf = () => fetchNui('assignCall', { callId: call.id, unitId: officer?.id });
  const unassignSelf = () => fetchNui('unassignCall', { callId: call.id, unitId: officer?.id });
  const closeCall = () => {
    fetchNui('closeCall', { callId: call.id });
    selectCall(null);
  };
  const setWaypoint = () => fetchNui('setWaypoint', { coords: call.coords });
  const removeWaypoint = () => fetchNui('removeWaypoint');
  const createBlip = () => fetchNui('createBlip', { callId: call.id, coords: call.coords, blip: call.blip });
  const removeBlip = () => fetchNui('removeBlip', { callId: call.id });
  const copyCoords = () => {
    copyToClipboard(`${call.coords.x.toFixed(2)}, ${call.coords.y.toFixed(2)}, ${call.coords.z.toFixed(2)}`);
    fetchNui('copyCoords');
  };
  const addNote = () => {
    if (!note.trim()) return;
    fetchNui('addNote', { callId: call.id, message: note.trim() });
    setNote('');
  };

  return (
    <Stack gap="1.2vh" style={{ height: '100%' }}>
      <Group gap="0.8vh">
        <ActionIcon variant="light" color="gray" radius="xs" size="2.8vh" onClick={() => selectCall(null)}>
          <ArrowLeft size="1.5vh" />
        </ActionIcon>
        <Text ff="digital-7" fz="2vh" fw={500} c={theme.colors[pColor][4]}>
          {call.code}
        </Text>
        <Text fz="1.8vh" fw={700}>
          {call.title}
        </Text>
        <Badge color={pColor} variant="filled" radius="xs" ml="auto">
          {priorityLabel(call.priority)}
        </Badge>
      </Group>

      <Text fz="1.2vh" c="dimmed">
        {call.description || 'No description provided.'}
      </Text>

      <Group gap="1.6vh">
        <InfoBit icon={MapPin} label={call.postal ? `Postal ${call.postal}` : 'Postal N/A'} />
        <InfoBit icon={Phone} label={call.callerPhone || call.caller} />
        <InfoBit icon={Clock} label={formatClock(call.createdAt)} />
      </Group>

      <Group gap="0.7vh" wrap="wrap">
        {!isAssignedToMe && call.status === 'pending' && (
          <Button size="xs" radius="xs" color="green" leftSection={<CheckCircle2 size="1.4vh" />} onClick={accept}>
            Accept
          </Button>
        )}
        {!isAssignedToMe ? (
          <Button size="xs" radius="xs" variant="light" leftSection={<UserPlus size="1.4vh" />} onClick={assignSelf}>
            Assign Me
          </Button>
        ) : (
          <Button size="xs" radius="xs" variant="light" color="orange" leftSection={<UserMinus size="1.4vh" />} onClick={unassignSelf}>
            Unassign Me
          </Button>
        )}
        <Button size="xs" radius="xs" variant="subtle" leftSection={<Navigation size="1.4vh" />} onClick={setWaypoint}>
          Waypoint
        </Button>
        <Button size="xs" radius="xs" variant="subtle" color="gray" leftSection={<MapPinOff size="1.4vh" />} onClick={removeWaypoint}>
          Clear WP
        </Button>
        <Button size="xs" radius="xs" variant="subtle" onClick={createBlip}>
          Blip
        </Button>
        <Button size="xs" radius="xs" variant="subtle" color="gray" onClick={removeBlip}>
          Remove Blip
        </Button>
        <ActionIcon variant="subtle" radius="xs" size="2.8vh" onClick={copyCoords} title="Copy coordinates">
          <Copy size="1.4vh" />
        </ActionIcon>
        <Button size="xs" radius="xs" color="red" variant="light" leftSection={<XCircle size="1.4vh" />} onClick={closeCall} ml="auto">
          Close Call
        </Button>
      </Group>

      <Divider color={theme.colors.dark[6]} />

      <Group align="flex-start" gap="1.6vh" style={{ flex: 1, minHeight: 0 }}>
        <Box style={{ flex: 1 }}>
          <Text fz="0.95vh" c="dimmed" tt="uppercase" fw={700} mb="0.6vh">
            Assigned Units ({call.assignedUnits.length})
          </Text>
          <Stack gap="0.6vh">
            {call.assignedUnits.length === 0 && (
              <Text fz="1.2vh" c="dimmed">
                No units assigned.
              </Text>
            )}
            {call.assignedUnits.map((u) => (
              <Group
                key={u.id}
                justify="space-between"
                p="0.6vh"
                style={{
                  borderRadius: theme.radius.xs,
                  border: `0.2vh solid ${alpha(theme.colors.dark[8], 0.7)}`,
                  backgroundColor: theme.colors.dark[8],
                }}
              >
                <Text fz="1.2vh">
                  {u.callsign} · {u.name}
                </Text>
                <ActionIcon
                  size="2.2vh"
                  variant="subtle"
                  color="red"
                  onClick={() => fetchNui('unassignCall', { callId: call.id, unitId: u.id })}
                >
                  <XCircle size="1.3vh" />
                </ActionIcon>
              </Group>
            ))}
          </Stack>
        </Box>

        <Box style={{ flex: 1.2, minHeight: 0, display: 'flex', flexDirection: 'column' }}>
          <Text fz="0.95vh" c="dimmed" tt="uppercase" fw={700} mb="0.6vh">
            Notes
          </Text>
          <ScrollArea style={{ flex: 1 }} scrollbarSize={4}>
            <Stack gap="0.5vh">
              {call.notes.length === 0 && (
                <Text fz="1.2vh" c="dimmed">
                  No notes yet.
                </Text>
              )}
              {call.notes.map((n) => (
                <Box key={n.id} style={{ fontSize: '1.1vh' }}>
                  <Text fz="1.1vh" fw={700} span>
                    {n.author}:{' '}
                  </Text>
                  <Text fz="1.1vh" span c="dimmed">
                    {n.message}
                  </Text>
                </Box>
              ))}
            </Stack>
          </ScrollArea>
          <Group gap="0.5vh" mt="0.7vh">
            <Textarea
              placeholder="Add a note..."
              value={note}
              onChange={(e) => setNote(e.currentTarget.value)}
              autosize
              minRows={1}
              maxRows={3}
              size="xs"
              radius="xs"
              style={{ flex: 1 }}
            />
            <ActionIcon variant="filled" color="blue" radius="xs" onClick={addNote}>
              <Send size="1.4vh" />
            </ActionIcon>
          </Group>
        </Box>
      </Group>
    </Stack>
  );
}

function InfoBit({ icon: Icon, label }: { icon: any; label: string }) {
  const theme = useMantineTheme();
  return (
    <Group gap="0.4vh">
      <Icon size="1.3vh" color={theme.colors.dark[2]} />
      <Text fz="1.1vh" c="dimmed">
        {label}
      </Text>
    </Group>
  );
}
