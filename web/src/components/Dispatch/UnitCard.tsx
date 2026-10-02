import { alpha, Badge, Box, Group, Select, Stack, Text, useMantineTheme } from '@mantine/core';
import type { DispatchUnit, DispatchUnitStatusDef } from '../../types/dispatch';
import { fetchNui } from '../../utils/fetchNui';
import { statusColor } from '../../utils/misc';
import { useDispatchStore } from '../../store/dispatchStore';

export default function UnitCard({ unit, statuses }: { unit: DispatchUnit; statuses: DispatchUnitStatusDef[] }) {
  const theme = useMantineTheme();
  const officer = useDispatchStore((s) => s.meta?.officer);
  const isSelf = officer?.id === unit.id;
  const statusDef = statuses.find((s) => s.id === unit.status);
  const dotColor = statusColor(statusDef?.color || 'gray');

  return (
    <Box
      style={{
        borderRadius: theme.radius.xs,
        border: `0.2vh solid ${alpha(theme.colors.dark[8], 0.7)}`,
        backgroundColor: theme.colors.dark[8],
        boxShadow: `0 0 10px ${theme.colors.dark[8]}`,
        padding: '0.8vh 1.2vh',
      }}
    >
      <Group justify="space-between" wrap="nowrap">
        <Stack gap="0.15vh">
          <Group gap="0.6vh">
            <Text ff="digital-7" fz="1.6vh" fw={500} c="blue.4">
              {unit.callsign}
            </Text>
            <Text fz="1.2vh" fw={700}>{unit.name}</Text>
            {isSelf && (
              <Badge size="xs" variant="outline" color="blue" radius="xs" tt="none">
                You
              </Badge>
            )}
          </Group>
          <Text fz="1vh" c="dimmed">
            {unit.jobLabel} · {unit.gradeLabel}
            {unit.currentCall ? ` · on ${unit.currentCall}` : ''}
          </Text>
        </Stack>

        <Group gap="0.6vh">
          <Box
            style={{
              width: '0.8vh',
              height: '0.8vh',
              borderRadius: 999,
              background: dotColor,
              boxShadow: `0 0 6px ${dotColor}`,
            }}
          />
          {isSelf ? (
            <Select
              size="xs"
              radius="xs"
              w="9.5vw"
              value={unit.status}
              data={statuses.filter((s) => s.selectable).map((s) => ({ value: s.id, label: s.label }))}
              onChange={(value) => value && fetchNui('setStatus', { status: value })}
            />
          ) : (
            <Text fz="1vh" c="dimmed" w="8vw" ta="right">
              {statusDef?.label || unit.status}
            </Text>
          )}
        </Group>
      </Group>
    </Box>
  );
}
