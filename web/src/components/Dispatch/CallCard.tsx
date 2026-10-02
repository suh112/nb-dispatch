import { alpha, Badge, Box, Group, Stack, Text, useMantineTheme } from '@mantine/core';
import { MapPin, Clock } from 'lucide-react';
import type { DispatchCall } from '../../types/dispatch';
import { priorityColor, priorityLabel, timeAgo } from '../../utils/misc';

export default function CallCard({ call, onClick }: { call: DispatchCall; onClick: () => void }) {
  const theme = useMantineTheme();
  const pColor = priorityColor(call.priority);

  return (
    <Box
      onClick={onClick}
      style={{
        cursor: 'pointer',
        borderRadius: theme.radius.xs,
        border: `0.2vh solid ${alpha(theme.colors.dark[8], 0.7)}`,
        borderLeft: `0.4vh solid ${theme.colors[pColor][6]}`,
        backgroundColor: theme.colors.dark[8],
        boxShadow: `0 0 10px ${theme.colors.dark[8]}`,
        padding: '0.9vh 1.2vh',
        transition: 'box-shadow 160ms ease',
      }}
    >
      <Stack gap="0.4vh">
        <Group justify="space-between" wrap="nowrap">
          <Group gap="0.8vh" wrap="nowrap">
            <Text ff="digital-7" fz="1.8vh" fw={500} c={theme.colors[pColor][4]}>
              {call.code}
            </Text>
            <Text fz="1.3vh" fw={700}>
              {call.title}
            </Text>
          </Group>
          <Badge color={pColor} variant="light" radius="xs" size="sm">
            {priorityLabel(call.priority)}
          </Badge>
        </Group>

        <Text fz="1.1vh" c="dimmed" lineClamp={1}>
          {call.description || 'No description provided.'}
        </Text>

        <Group gap="1.2vh" mt="0.2vh">
          <Group gap="0.3vh">
            <MapPin size="1.3vh" color={theme.colors.dark[2]} />
            <Text fz="1vh" c="dimmed">
              {call.postal ? `Postal ${call.postal}` : call.street || 'Unknown location'}
            </Text>
          </Group>
          <Group gap="0.3vh">
            <Clock size="1.3vh" color={theme.colors.dark[2]} />
            <Text fz="1vh" c="dimmed">
              {timeAgo(call.createdAt)}
            </Text>
          </Group>
          {call.assignedUnits.length > 0 && (
            <Badge size="xs" variant="outline" color="blue" radius="xs" tt="none">
              {call.assignedUnits.length} unit{call.assignedUnits.length > 1 ? 's' : ''}
            </Badge>
          )}
          <Badge size="xs" variant="dot" color={call.status === 'pending' ? 'yellow' : 'blue'} tt="none" ml="auto">
            {call.status}
          </Badge>
        </Group>
      </Stack>
    </Box>
  );
}
