import { useEffect, useState } from 'react';
import { alpha, Box, Button, Group, Stack, Text, ThemeIcon, useMantineTheme } from '@mantine/core';
import type { MantineTheme } from '@mantine/core';
import { Siren, Skull } from 'lucide-react';
import { useDispatchStore } from '../../store/dispatchStore';

function bannerStyle(theme: MantineTheme, color: string) {
  return {
    minWidth: '26vw',
    borderRadius: theme.radius.sm,
    backgroundColor: theme.colors.dark[8],
    border: `0.2vh solid ${alpha((theme.colors as any)[color][6], 0.6)}`,
    boxShadow: `0 0 18px ${theme.colors.dark[9]}`,
    padding: '1.4vh 2vh',
  };
}

export default function CriticalAlertOverlay() {
  const theme = useMantineTheme();
  const panic = useDispatchStore((s) => s.panic);
  const unitDown = useDispatchStore((s) => s.unitDown);
  const setPanic = useDispatchStore((s) => s.setPanic);
  const setUnitDown = useDispatchStore((s) => s.setUnitDown);
  const [flash, setFlash] = useState(true);

  useEffect(() => {
    if (!panic && !unitDown) return;
    const id = setInterval(() => setFlash((f) => !f), 500);
    return () => clearInterval(id);
  }, [panic, unitDown]);

  useEffect(() => {
    if (!panic) return;
    const t = setTimeout(() => setPanic(null), 15000);
    return () => clearTimeout(t);
  }, [panic, setPanic]);

  useEffect(() => {
    if (!unitDown) return;
    const t = setTimeout(() => setUnitDown(null), 20000);
    return () => clearTimeout(t);
  }, [unitDown, setUnitDown]);

  if (!panic && !unitDown) return null;

  const glowColor = panic ? theme.colors.red[7] : theme.colors.orange[7];

  return (
    <Box
      style={{
        position: 'fixed',
        inset: 0,
        pointerEvents: 'none',
        zIndex: 300,
        boxShadow: flash
          ? `inset 0 0 18vh ${alpha(glowColor, 0.55)}`
          : `inset 0 0 18vh ${alpha(glowColor, 0.2)}`,
        transition: 'box-shadow 400ms ease',
      }}
    >
      <Stack
        gap="0.8vh"
        style={{
          position: 'absolute',
          top: '2.5vh',
          left: '50%',
          transform: 'translateX(-50%)',
          pointerEvents: 'auto',
        }}
      >
        {panic && (
          <Box style={bannerStyle(theme, 'red')}>
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
        )}

        {unitDown && (
          <Box style={bannerStyle(theme, 'orange')}>
            <Group gap="1vh" wrap="nowrap">
              <ThemeIcon size="4vh" radius="xs" variant="light" color="orange">
                <Skull size="2vh" style={{ filter: `drop-shadow(0 0 4px ${alpha(theme.colors.orange[4], 0.6)})` }} />
              </ThemeIcon>
              <Stack gap={0} style={{ flex: 1 }}>
                <Text fz="1.6vh" fw={900} c="orange.4">
                  UNIT DOWN
                </Text>
                <Text fz="1.3vh">
                  {unitDown.callsign} · {unitDown.name}
                </Text>
              </Stack>
              <Button size="xs" radius="xs" variant="subtle" color="gray" onClick={() => setUnitDown(null)}>
                Dismiss
              </Button>
            </Group>
          </Box>
        )}
      </Stack>
    </Box>
  );
}
