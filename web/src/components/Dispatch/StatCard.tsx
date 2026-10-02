import { alpha, Box, Group, Stack, Text, ThemeIcon, useMantineTheme } from '@mantine/core';
import type { LucideIcon } from 'lucide-react';

export default function StatCard({
  icon: Icon,
  label,
  value,
  color = 'blue',
}: {
  icon: LucideIcon;
  label: string;
  value: string | number;
  color?: string;
}) {
  const theme = useMantineTheme();

  return (
    <Box
      style={{
        flex: 1,
        minWidth: '9vw',
        borderRadius: theme.radius.xs,
        border: `0.2vh solid ${alpha(theme.colors.dark[8], 1)}`,
        backgroundColor: theme.colors.dark[8],
        boxShadow: `0 0 10px ${theme.colors.dark[8]}`,
        padding: '1vh 1.2vh',
      }}
    >
      <Group gap="1vh" wrap="nowrap">
        <ThemeIcon size="3.4vh" radius="xs" variant="light" color={color}>
          <Icon size="1.7vh" style={{ filter: `drop-shadow(0 0 4px ${alpha((theme.colors as any)[color][4], 0.5)})` }} />
        </ThemeIcon>
        <Stack gap={0}>
          <Text
            ff="digital-7"
            fz="2.6vh"
            fw={500}
            lh={1}
            c={(theme.colors as any)[color][4]}
            style={{ textShadow: `0 0 10px ${alpha((theme.colors as any)[color][4], 0.6)}` }}
          >
            {value}
          </Text>
          <Text fz="0.95vh" c="dimmed" tt="uppercase" fw={700} style={{ letterSpacing: '0.05vh' }}>
            {label}
          </Text>
        </Stack>
      </Group>
    </Box>
  );
}
