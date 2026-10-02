import { alpha, Box, Flex, Group, ActionIcon, Badge, Stack, Text, ThemeIcon, useMantineTheme } from '@mantine/core';
import { X, Radio } from 'lucide-react';
import { useDispatchStore } from '../../store/dispatchStore';

export default function Header({ onClose }: { onClose: () => void }) {
  const theme = useMantineTheme();
  const meta = useDispatchStore((s) => s.meta);
  const officer = meta?.officer;

  return (
    <Flex
      align="center"
      justify="space-between"
      p="0.85vh"
      style={{
        backgroundColor: theme.colors.dark[7],
        boxShadow: `0 0 10px ${theme.colors.dark[7]}`,
        flexShrink: 0,
      }}
    >
      <Group gap="1vh">
        <Box
          style={{
            borderRadius: theme.radius.xs,
            border: `0.2vh solid ${alpha(theme.colors.dark[8], 1)}`,
            backgroundColor: theme.colors.dark[8],
            boxShadow: `0 0 12px ${alpha(theme.colors.dark[9], 0.55)}`,
          }}
        >
          <ThemeIcon
            size="5vh"
            radius="xs"
            variant="light"
            color="red"
            style={{ border: `0.2vh solid ${alpha(theme.colors.dark[8], 0.5)}` }}
          >
            <Radio
              size="3vh"
              style={{ filter: `drop-shadow(0 0 4px ${alpha(theme.colors.red[4], 0.5)})` }}
            />
          </ThemeIcon>
        </Box>

        <Stack gap="0.1vh">
          <Text fz="2.2vh" fw={900} c="gray.0" lh={1.1}>
            NB <Text component="span" c="red.5" fz="2.2vh" fw={900}>DISPATCH</Text>
          </Text>
          <Text fz="1.2vh" fw={700} c="dimmed" lh={1.1}>
            NullBound - Veyx (AJ)
          </Text>
        </Stack>
      </Group>

      <Group gap="1vh">
        {officer && (
          <Badge
            variant="light"
            color="blue"
            radius="xs"
            style={{ textTransform: 'none' }}
          >
            {officer.callsign} · {officer.gradeLabel}
          </Badge>
        )}
        <ActionIcon variant="light" color="red" radius="xs" size="3.5vh" onClick={onClose} aria-label="Close dispatch">
          <X size="1.7vh" />
        </ActionIcon>
      </Group>
    </Flex>
  );
}
