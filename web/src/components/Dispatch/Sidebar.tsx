import { alpha, Box, Group, Stack, Text, ThemeIcon, UnstyledButton, useMantineTheme } from '@mantine/core';
import { LayoutDashboard, PhoneCall, Users } from 'lucide-react';
import { useDispatchStore } from '../../store/dispatchStore';

const TABS = [
  { id: 'dashboard', label: 'Dashboard', description: 'Overview & live calls', icon: LayoutDashboard },
  { id: 'calls', label: 'Calls', description: 'Active dispatch calls', icon: PhoneCall },
  { id: 'units', label: 'Units', description: 'Online personnel', icon: Users },
] as const;

export default function Sidebar() {
  const theme = useMantineTheme();
  const activeTab = useDispatchStore((s) => s.activeTab);
  const setActiveTab = useDispatchStore((s) => s.setActiveTab);
  const selectCall = useDispatchStore((s) => s.selectCall);
  const calls = useDispatchStore((s) => s.calls);

  const pendingCount = calls.filter((c) => c.status === 'pending').length;

  return (
    <Stack gap="0.7vh" w="13.5vw" style={{ flexShrink: 0 }}>
      {TABS.map((tab) => {
        const Icon = tab.icon;
        const active = activeTab === tab.id;

        return (
          <UnstyledButton
            key={tab.id}
            onClick={() => {
              setActiveTab(tab.id);
              if (tab.id !== 'calls') selectCall(null);
            }}
            p="0.7vh"
            style={{
              borderRadius: theme.radius.xs,
              backgroundColor: active ? alpha(theme.colors.blue[4], 0.1) : theme.colors.dark[7],
              filter: active ? `drop-shadow(0 0 4px ${alpha(theme.colors.blue[4], 0.45)})` : 'none',
              transition: 'background-color 160ms ease, filter 160ms ease',
            }}
          >
            <Group gap="0.8vh" wrap="nowrap">
              <ThemeIcon size="3.2vh" radius="xs" variant="light" color={active ? 'blue' : 'gray'}>
                <Icon size="1.75vh" />
              </ThemeIcon>
              <Stack gap={0} style={{ minWidth: 0, flex: 1 }}>
                <Text fz="1.3vh" fw={800} c={active ? 'blue.2' : 'gray.1'}>
                  {tab.label}
                </Text>
                <Text fz="0.95vh" fw={500} c="dimmed" truncate>
                  {tab.description}
                </Text>
              </Stack>
              {tab.id === 'calls' && pendingCount > 0 && (
                <Box
                  style={{
                    background: theme.colors.red[7],
                    color: 'white',
                    borderRadius: 999,
                    fontSize: '1vh',
                    padding: '0.1vh 0.6vh',
                    fontWeight: 700,
                  }}
                >
                  {pendingCount}
                </Box>
              )}
            </Group>
          </UnstyledButton>
        );
      })}
    </Stack>
  );
}
