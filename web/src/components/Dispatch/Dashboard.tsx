import { alpha, Box, Group, Stack, Text, Badge, useMantineTheme } from '@mantine/core';
import { PhoneCall, Clock, UserCheck, Users, AlertTriangle, Activity } from 'lucide-react';
import { useDispatchStore } from '../../store/dispatchStore';
import { priorityColor, timeAgo } from '../../utils/misc';
import StatCard from './StatCard';

export default function Dashboard() {
  const theme = useMantineTheme();
  const calls = useDispatchStore((s) => s.calls);
  const units = useDispatchStore((s) => s.units);
  const officer = useDispatchStore((s) => s.meta?.officer);
  const setActiveTab = useDispatchStore((s) => s.setActiveTab);
  const selectCall = useDispatchStore((s) => s.selectCall);

  const pending = calls.filter((c) => c.status === 'pending').length;
  const active = calls.filter((c) => c.status === 'active').length;
  const assigned = calls.filter((c) => c.assignedUnits.length > 0).length;
  const priority1 = calls.filter((c) => c.priority === 1).length;
  const online = units.length;
  const available = units.filter((u) => u.status === 'available').length;

  const openCall = (id: string) => {
    setActiveTab('calls');
    selectCall(id);
  };

  return (
    <Stack gap="1.4vh">
      <Group gap="1vh" wrap="wrap" grow>
        <StatCard icon={PhoneCall} label="Active Calls" value={active} color="blue" />
        <StatCard icon={Clock} label="Pending" value={pending} color="yellow" />
        <StatCard icon={UserCheck} label="Assigned" value={assigned} color="grape" />
        <StatCard icon={AlertTriangle} label="Priority 1" value={priority1} color="red" />
        <StatCard icon={Users} label="Online" value={online} color="blue" />
        <StatCard icon={Activity} label="Available" value={available} color="green" />
      </Group>

      {officer && (
        <Box
          style={{
            borderRadius: theme.radius.xs,
            border: `0.2vh solid ${alpha(theme.colors.dark[8], 0.7)}`,
            backgroundColor: theme.colors.dark[8],
            boxShadow: `0 0 10px ${theme.colors.dark[8]}`,
            padding: '1vh 1.2vh',
          }}
        >
          <Text fz="0.95vh" c="dimmed" tt="uppercase" fw={700} mb="0.3vh">
            Your Status
          </Text>
          <Group justify="space-between">
            <Text fz="1.4vh" fw={700}>
              {officer.callsign} · {officer.name}
            </Text>
            <Badge color="blue" variant="light" radius="xs" tt="none">
              {officer.jobLabel} - {officer.gradeLabel}
            </Badge>
          </Group>
        </Box>
      )}

      <Box>
        <Text fz="0.95vh" c="dimmed" tt="uppercase" fw={700} mb="0.8vh">
          Live Calls
        </Text>
        <Stack gap="0.6vh">
          {calls.length === 0 && (
            <Text fz="1.3vh" c="dimmed">
              No active calls.
            </Text>
          )}
          {calls.slice(0, 6).map((call) => (
            <Box
              key={call.id}
              onClick={() => openCall(call.id)}
              style={{
                cursor: 'pointer',
                borderRadius: theme.radius.xs,
                border: `0.2vh solid ${alpha(theme.colors.dark[8], 0.7)}`,
                borderLeft: `0.35vh solid ${theme.colors[priorityColor(call.priority)][6]}`,
                backgroundColor: theme.colors.dark[8],
                padding: '0.7vh 1vh',
              }}
            >
              <Group justify="space-between" wrap="nowrap">
                <Group gap="0.8vh" wrap="nowrap">
                  <Text ff="digital-7" fz="1.6vh" fw={500} c={theme.colors[priorityColor(call.priority)][4]}>
                    {call.code}
                  </Text>
                  <Text fz="1.3vh">{call.title}</Text>
                </Group>
                <Text fz="1vh" c="dimmed">
                  {timeAgo(call.createdAt)}
                </Text>
              </Group>
            </Box>
          ))}
        </Stack>
      </Box>
    </Stack>
  );
}
