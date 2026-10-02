import { useEffect } from 'react';
import { alpha, Box, Group, Stack, Text, useMantineTheme } from '@mantine/core';
import { CheckCircle2, XCircle, Info } from 'lucide-react';
import { useDispatchStore } from '../../store/dispatchStore';

export default function NotificationStack() {
  const theme = useMantineTheme();
  const notifications = useDispatchStore((s) => s.notifications);
  const dismiss = useDispatchStore((s) => s.dismissNotification);

  useEffect(() => {
    const timers = notifications.map((n) => setTimeout(() => dismiss(n.id), 4000));
    return () => timers.forEach(clearTimeout);
  }, [notifications, dismiss]);

  if (notifications.length === 0) return null;

  return (
    <Stack
      gap="0.6vh"
      style={{
        position: 'fixed',
        top: '2vh',
        right: '2vh',
        zIndex: 999,
        pointerEvents: 'none',
      }}
    >
      {notifications.map((n) => {
        const Icon = n.type === 'success' ? CheckCircle2 : n.type === 'error' ? XCircle : Info;
        const color = n.type === 'success' ? 'green' : n.type === 'error' ? 'red' : 'blue';
        const accent = (theme.colors as any)[color][6];
        return (
          <Box
            key={n.id}
            style={{
              pointerEvents: 'auto',
              borderRadius: theme.radius.xs,
              backgroundColor: theme.colors.dark[8],
              border: `0.2vh solid ${alpha(accent, 0.6)}`,
              boxShadow: `0 0 10px ${alpha(accent, 0.3)}`,
              padding: '0.8vh 1.2vh',
              minWidth: '18vw',
            }}
          >
            <Group gap="0.6vh" wrap="nowrap">
              <Icon size="1.5vh" color={(theme.colors as any)[color][4]} style={{ filter: `drop-shadow(0 0 4px ${alpha(accent, 0.5)})` }} />
              <Text fz="1.2vh">{n.message}</Text>
            </Group>
          </Box>
        );
      })}
    </Stack>
  );
}
