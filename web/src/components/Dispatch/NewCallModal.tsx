import { useState } from 'react';
import {
  alpha, Box, Button, Flex, Group, Select, Stack, Text, Textarea, TextInput, Transition, useMantineTheme,
} from '@mantine/core';
import { useDispatchStore } from '../../store/dispatchStore';
import { fetchNui } from '../../utils/fetchNui';

export default function NewCallModal() {
  const theme = useMantineTheme();
  const open = useDispatchStore((s) => s.newCallOpen);
  const setOpen = useDispatchStore((s) => s.setNewCallOpen);
  const callTypes = useDispatchStore((s) => s.meta?.callTypes) || {};

  const [type, setType] = useState<string | null>(null);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [priority, setPriority] = useState<string | null>('3');

  const close = () => {
    setOpen(false);
    setType(null);
    setTitle('');
    setDescription('');
    setPriority('3');
  };

  const submit = () => {
    fetchNui('createCall', {
      type: type || undefined,
      title: title || undefined,
      description,
      priority: priority ? Number(priority) : undefined,
    });
    close();
  };

  return (
    <Transition mounted={open} transition="pop" duration={160} timingFunction="ease">
      {(styles) => (
        <Flex
          pos="fixed"
          inset={0}
          align="center"
          justify="center"
          style={{ ...styles, zIndex: 400, backgroundColor: alpha(theme.colors.dark[9], 0.55) }}
          onClick={close}
        >
          <Box
            onClick={(e) => e.stopPropagation()}
            w="30vw"
            style={{
              borderRadius: theme.radius.sm,
              backgroundColor: theme.colors.dark[8],
              border: `0.2vh solid ${alpha(theme.colors.dark[6], 0.8)}`,
              boxShadow: `0 0 18px ${theme.colors.dark[9]}`,
              padding: '1.6vh',
            }}
          >
            <Text fz="1.6vh" fw={900} c="gray.0" mb="1.2vh">
              Create Dispatch Call
            </Text>

            <Stack gap="0.8vh">
              <Select
                label="Call type"
                placeholder="Custom"
                size="xs"
                radius="xs"
                data={Object.entries(callTypes).map(([key, cfg]) => ({ value: key, label: `${cfg.code} - ${cfg.title}` }))}
                value={type}
                onChange={setType}
                clearable
              />
              <TextInput
                label="Title"
                placeholder="Only needed for a custom call"
                size="xs"
                radius="xs"
                value={title}
                onChange={(e) => setTitle(e.currentTarget.value)}
              />
              <Textarea
                label="Description"
                size="xs"
                radius="xs"
                value={description}
                onChange={(e) => setDescription(e.currentTarget.value)}
                minRows={3}
              />
              <Select
                label="Priority"
                size="xs"
                radius="xs"
                data={[
                  { value: '1', label: '1 - Critical' },
                  { value: '2', label: '2 - High' },
                  { value: '3', label: '3 - Medium' },
                  { value: '4', label: '4 - Low' },
                ]}
                value={priority}
                onChange={setPriority}
              />
              <Group justify="flex-end" mt="0.4vh">
                <Button size="xs" radius="xs" variant="subtle" color="gray" onClick={close}>
                  Cancel
                </Button>
                <Button size="xs" radius="xs" color="red" onClick={submit}>
                  Create Call
                </Button>
              </Group>
            </Stack>
          </Box>
        </Flex>
      )}
    </Transition>
  );
}
