import type { CSSProperties } from 'react';
import {
  Box, Flex, Stack, Text, ThemeIcon, Transition, useMantineTheme,
} from '@mantine/core';
import { Radio } from 'lucide-react';
import { useDispatchStore } from '../../store/dispatchStore';
import { fetchNui } from '../../utils/fetchNui';
import Header from './Header';
import Sidebar from './Sidebar';
import Dashboard from './Dashboard';
import CallList from './CallList';
import CallDetail from './CallDetail';
import UnitList from './UnitList';
import PanicButton from './PanicButton';
import NewCallModal from './NewCallModal';

export default function Shell() {
  const theme = useMantineTheme();
  const open = useDispatchStore((s) => s.open);
  const authorized = useDispatchStore((s) => s.authorized);
  const activeTab = useDispatchStore((s) => s.activeTab);
  const selectedCallId = useDispatchStore((s) => s.selectedCallId);
  const setOpen = useDispatchStore((s) => s.setOpen);

  const close = () => {
    fetchNui('close');
    setOpen(false);
  };

  return (
    <Transition mounted={open} transition="slide-up" duration={250} timingFunction="ease">
      {(transitionStyles: CSSProperties) => (
        <Flex
          pos="fixed"
          inset={0}
          align="center"
          justify="center"
          style={{ pointerEvents: 'none', zIndex: 200, ...transitionStyles }}
        >
          <Box
            w="74vw"
            h="76vh"
            style={{
              pointerEvents: 'auto',
              borderRadius: theme.radius.sm,
              backgroundColor: theme.colors.dark[8],
              boxShadow: `0 0 18px ${theme.colors.dark[9]}`,
              overflow: 'hidden',
              display: 'flex',
              flexDirection: 'column',
            }}
          >
            <Header onClose={close} />

            {!authorized ? (
              <Stack align="center" justify="center" style={{ flex: 1 }} gap="0.4vh">
                <ThemeIcon size="6vh" radius="xs" variant="light" color="red">
                  <Radio size="3vh" />
                </ThemeIcon>
                <Text fz="2vh" fw={900} c="red.4">
                  NOT AUTHORIZED
                </Text>
                <Text fz="1.3vh" c="dimmed">
                  You are not currently on duty with a department that uses dispatch.
                </Text>
              </Stack>
            ) : (
              <Flex gap="1.2vh" p="1.2vh" h="calc(100% - 6.8vh)" style={{ backgroundColor: theme.colors.dark[8] }}>
                <Sidebar />

                <Box
                  style={{
                    flex: 1,
                    minWidth: 0,
                    minHeight: 0,
                    overflowY: 'auto',
                    borderRadius: theme.radius.xs,
                    backgroundColor: theme.colors.dark[7],
                    boxShadow: `0 0 10px ${theme.colors.dark[7]}`,
                    padding: '1.2vh',
                  }}
                >
                  {activeTab === 'dashboard' && <Dashboard />}
                  {activeTab === 'calls' && !selectedCallId && <CallList />}
                  {activeTab === 'calls' && selectedCallId && <CallDetail />}
                  {activeTab === 'units' && <UnitList />}
                </Box>
              </Flex>
            )}
          </Box>

          {authorized && <PanicButton />}
          <NewCallModal />
        </Flex>
      )}
    </Transition>
  );
}
