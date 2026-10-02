import { useEffect, useState } from 'react';
import { alpha, Box, Button, Group, Stack, Text, ThemeIcon, useMantineTheme } from '@mantine/core';
import { Siren } from 'lucide-react';
import { useDispatchStore } from '../../store/dispatchStore';

export default function PanicOverlay() {
  const theme = useMantineTheme();
  const panic = useDispatchStore((s) => s.panic);
  const setPanic = useDispatchStore((s) => s.setPanic);
  const [flash, setFlash] = useState(true);

  useEffect(() => {
    if (!panic) return;
    const id = setInterval(() => setFlash((f) => !f), 500);
    const timeout = setTimeout(() => setPanic(null), 15000);
    return () => {
      clearInterval(id);
      clearTimeout(timeout);
    };
  }, [panic, setPanic]);

  if (!panic) return null;

  return (
    <Box
      style={{
        position: 'fixed',
        inset: 0,
        pointerEvents: 'none',
        zIndex: 300,
        boxShadow: flash
          ? `inset 0 0 18vh ${alpha(theme.colors.red[7], 0.55)}`
          : `inset 0 0 18vh ${alpha(theme.colors.red[7], 0.2)}`,
        transition: 'box-shadow 400ms ease',
      }}
    >
      <Box
        style={{
          position: 'absolute',
          top: '2.5vh',
          left: '50%',
          transform: 'translateX(-50%)',
          pointerEvents: 'auto',
          borderRadius: theme.radius.sm,
          backgroundColor: theme.colors.dark[8],
          border: `0.2vh solid ${alpha(theme.colors.red[6], 0.6)}`,
          boxShadow: `0 0 18px ${theme.colors.dark[9]}`,
          padding: '1.4vh 2vh',
          minWidth: '26vw',
        }}
      >
        <Group gap="1vh" wrap="nowrap">
          <ThemeIcon size="4vh" radius="xs" variant="light" color="red">
            <Siren size="2vh" style={{ filter: `drop-shadow(0 0 4px ${alpha(theme.colors.red[4], 0.6)})` }} />
          </ThemeIcon>
          <Stack gap={0} style={{ flex: 1 }}>
            <Text fz="1.6vh" fw={900} c="red.4">
              OFFICER PANIC
            </Text>
            <Text fz="1.3vh">
              {panic.callsign} · {panic.name}
            </Text>
          </Stack>
          <Button size="xs" radius="xs" variant="subtle" color="gray" onClick={() => setPanic(null)}>
            Dismiss
          </Button>
        </Group>
      </Box>
    </Box>
  );
}
