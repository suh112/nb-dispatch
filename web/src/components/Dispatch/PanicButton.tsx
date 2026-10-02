import { useState } from 'react';
import { alpha, Box, Tooltip, useMantineTheme } from '@mantine/core';
import { Siren } from 'lucide-react';
import { fetchNui } from '../../utils/fetchNui';

export default function PanicButton() {
  const theme = useMantineTheme();
  const [cooling, setCooling] = useState(false);

  const trigger = () => {
    if (cooling) return;
    fetchNui('panic');
    setCooling(true);
    setTimeout(() => setCooling(false), 10000);
  };

  return (
    <Tooltip label={cooling ? 'On cooldown' : 'Panic Button'} position="left">
      <Box
        onClick={trigger}
        style={{
          position: 'absolute',
          right: 'calc(13vw)',
          bottom: '3vh',
          width: '5.5vh',
          height: '5.5vh',
          borderRadius: '50%',
          backgroundColor: theme.colors.dark[8],
          border: `0.2vh solid ${alpha(cooling ? theme.colors.dark[5] : theme.colors.red[6], 0.8)}`,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          cursor: cooling ? 'not-allowed' : 'pointer',
          boxShadow: cooling ? 'none' : `0 0 14px ${alpha(theme.colors.red[6], 0.7)}`,
          pointerEvents: 'auto',
          transition: 'box-shadow 150ms ease, border-color 150ms ease',
        }}
      >
        <Siren
          size="2.6vh"
          color={cooling ? theme.colors.dark[3] : theme.colors.red[4]}
          style={{ filter: cooling ? 'none' : `drop-shadow(0 0 4px ${alpha(theme.colors.red[4], 0.6)})` }}
        />
      </Box>
    </Tooltip>
  );
}
