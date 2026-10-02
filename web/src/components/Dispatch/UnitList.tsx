import { useMemo, useState } from 'react';
import { Box, Group, Stack, Text, TextInput, Select } from '@mantine/core';
import { Search } from 'lucide-react';
import { useDispatchStore } from '../../store/dispatchStore';
import UnitCard from './UnitCard';

export default function UnitList() {
  const units = useDispatchStore((s) => s.units);
  const statuses = useDispatchStore((s) => s.meta?.statuses) || [];

  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<string | null>(null);
  const [deptFilter, setDeptFilter] = useState<string | null>(null);

  const departments = useMemo(() => Array.from(new Set(units.map((u) => u.jobLabel))), [units]);

  const filtered = useMemo(() => {
    return units.filter((u) => {
      if (search) {
        const q = search.toLowerCase();
        if (!u.callsign.toLowerCase().includes(q) && !u.name.toLowerCase().includes(q)) return false;
      }
      if (statusFilter && u.status !== statusFilter) return false;
      if (deptFilter && u.jobLabel !== deptFilter) return false;
      return true;
    });
  }, [units, search, statusFilter, deptFilter]);

  return (
    <Stack gap="1vh" style={{ height: '100%' }}>
      <Text fz="1.8vh" fw={900} c="gray.0">
        Units Online ({units.length})
      </Text>

      <Group gap="0.6vh">
        <TextInput
          placeholder="Search units..."
          leftSection={<Search size="1.4vh" />}
          value={search}
          onChange={(e) => setSearch(e.currentTarget.value)}
          style={{ flex: 1 }}
          size="xs"
          radius="xs"
        />
        <Select
          placeholder="Status"
          data={statuses.map((s) => ({ value: s.id, label: s.label }))}
          value={statusFilter}
          onChange={setStatusFilter}
          clearable
          size="xs"
          radius="xs"
          w="9.5vw"
        />
        <Select
          placeholder="Department"
          data={departments.map((d) => ({ value: d, label: d }))}
          value={deptFilter}
          onChange={setDeptFilter}
          clearable
          size="xs"
          radius="xs"
          w="10vw"
        />
      </Group>

      <Box style={{ flex: 1, overflowY: 'auto', paddingRight: '0.3vh' }}>
        <Stack gap="0.6vh">
          {filtered.length === 0 && (
            <Text fz="1.3vh" c="dimmed" ta="center" mt="2vh">
              No units match your filters.
            </Text>
          )}
          {filtered.map((unit) => (
            <UnitCard key={unit.id} unit={unit} statuses={statuses} />
          ))}
        </Stack>
      </Box>
    </Stack>
  );
}
