import { useMemo, useState } from 'react';
import { alpha, Box, Group, Stack, Text, TextInput, Select, Button, useMantineTheme } from '@mantine/core';
import { Search, Plus } from 'lucide-react';
import { useDispatchStore } from '../../store/dispatchStore';
import CallCard from './CallCard';

export default function CallList() {
  const theme = useMantineTheme();
  const calls = useDispatchStore((s) => s.calls);
  const selectCall = useDispatchStore((s) => s.selectCall);
  const setNewCallOpen = useDispatchStore((s) => s.setNewCallOpen);

  const [search, setSearch] = useState('');
  const [priorityFilter, setPriorityFilter] = useState<string | null>(null);
  const [statusFilter, setStatusFilter] = useState<string | null>(null);
  const [assignedFilter, setAssignedFilter] = useState<string | null>(null);

  const filtered = useMemo(() => {
    return calls.filter((c) => {
      if (search) {
        const q = search.toLowerCase();
        if (!c.title.toLowerCase().includes(q) && !c.code.toLowerCase().includes(q) && !c.description.toLowerCase().includes(q)) {
          return false;
        }
      }
      if (priorityFilter && String(c.priority) !== priorityFilter) return false;
      if (statusFilter && c.status !== statusFilter) return false;
      if (assignedFilter === 'assigned' && c.assignedUnits.length === 0) return false;
      if (assignedFilter === 'unassigned' && c.assignedUnits.length > 0) return false;
      return true;
    });
  }, [calls, search, priorityFilter, statusFilter, assignedFilter]);

  return (
    <Stack gap="1vh" style={{ height: '100%' }}>
      <Group justify="space-between">
        <Text fz="1.8vh" fw={900} c="gray.0">
          Active Calls
        </Text>
        <Button
          size="xs"
          radius="xs"
          color="red"
          leftSection={<Plus size="1.4vh" />}
          onClick={() => setNewCallOpen(true)}
        >
          New Call
        </Button>
      </Group>

      <Group gap="0.6vh">
        <TextInput
          placeholder="Search calls..."
          leftSection={<Search size="1.4vh" />}
          value={search}
          onChange={(e) => setSearch(e.currentTarget.value)}
          style={{ flex: 1 }}
          size="xs"
          radius="xs"
        />
        <Select
          placeholder="Priority"
          data={[
            { value: '1', label: 'Priority 1' },
            { value: '2', label: 'Priority 2' },
            { value: '3', label: 'Priority 3' },
            { value: '4', label: 'Priority 4' },
          ]}
          value={priorityFilter}
          onChange={setPriorityFilter}
          clearable
          size="xs"
          radius="xs"
          w="9vw"
        />
        <Select
          placeholder="Status"
          data={[
            { value: 'pending', label: 'Pending' },
            { value: 'active', label: 'Active' },
          ]}
          value={statusFilter}
          onChange={setStatusFilter}
          clearable
          size="xs"
          radius="xs"
          w="8vw"
        />
        <Select
          placeholder="Assigned"
          data={[
            { value: 'assigned', label: 'Assigned' },
            { value: 'unassigned', label: 'Unassigned' },
          ]}
          value={assignedFilter}
          onChange={setAssignedFilter}
          clearable
          size="xs"
          radius="xs"
          w="9vw"
        />
      </Group>

      <Box style={{ flex: 1, overflowY: 'auto', paddingRight: '0.3vh' }}>
        <Stack gap="0.6vh">
          {filtered.length === 0 && (
            <Text fz="1.3vh" c="dimmed" ta="center" mt="2vh">
              No calls match your filters.
            </Text>
          )}
          {filtered.map((call) => (
            <CallCard key={call.id} call={call} onClick={() => selectCall(call.id)} />
          ))}
        </Stack>
      </Box>
    </Stack>
  );
}
