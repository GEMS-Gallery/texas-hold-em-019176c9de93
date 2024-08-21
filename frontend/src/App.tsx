import React, { useState, useEffect } from 'react';
import { backend } from 'declarations/backend';
import { Container, Typography, Button, TextField, Box, Card, CardContent, CircularProgress } from '@mui/material';
import { styled } from '@mui/system';

const StyledCard = styled(Card)(({ theme }) => ({
  backgroundColor: theme.palette.primary.main,
  color: theme.palette.primary.contrastText,
  margin: theme.spacing(2),
  padding: theme.spacing(2),
}));

const App: React.FC = () => {
  const [gameState, setGameState] = useState<string>('');
  const [betAmount, setBetAmount] = useState<string>('');
  const [loading, setLoading] = useState<boolean>(false);

  const initGame = async () => {
    setLoading(true);
    try {
      const result = await backend.initGame();
      setGameState(result);
    } catch (error) {
      console.error('Error initializing game:', error);
    } finally {
      setLoading(false);
    }
  };

  const placeBet = async () => {
    setLoading(true);
    try {
      const result = await backend.placeBet(BigInt(betAmount));
      setGameState(result);
      setBetAmount('');
    } catch (error) {
      console.error('Error placing bet:', error);
    } finally {
      setLoading(false);
    }
  };

  const revealCommunityCards = async () => {
    setLoading(true);
    try {
      const result = await backend.revealCommunityCards();
      setGameState(result);
    } catch (error) {
      console.error('Error revealing community cards:', error);
    } finally {
      setLoading(false);
    }
  };

  const evaluateHands = async () => {
    setLoading(true);
    try {
      const result = await backend.evaluateHands();
      setGameState(result);
    } catch (error) {
      console.error('Error evaluating hands:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Container maxWidth="sm">
      <Typography variant="h2" component="h1" gutterBottom align="center">
        Texas Hold'em
      </Typography>
      <StyledCard>
        <CardContent>
          <Typography variant="h6" component="h2" gutterBottom>
            Game State
          </Typography>
          <Typography variant="body1">{gameState}</Typography>
        </CardContent>
      </StyledCard>
      <Box display="flex" flexDirection="column" alignItems="center">
        <Button variant="contained" color="primary" onClick={initGame} disabled={loading}>
          Initialize Game
        </Button>
        <Box mt={2} display="flex" alignItems="center">
          <TextField
            label="Bet Amount"
            type="number"
            value={betAmount}
            onChange={(e) => setBetAmount(e.target.value)}
            disabled={loading}
          />
          <Button variant="contained" color="secondary" onClick={placeBet} disabled={loading || !betAmount}>
            Place Bet
          </Button>
        </Box>
        <Button variant="contained" color="primary" onClick={revealCommunityCards} disabled={loading}>
          Reveal Community Cards
        </Button>
        <Button variant="contained" color="primary" onClick={evaluateHands} disabled={loading}>
          Evaluate Hands
        </Button>
      </Box>
      {loading && (
        <Box display="flex" justifyContent="center" mt={2}>
          <CircularProgress />
        </Box>
      )}
    </Container>
  );
};

export default App;
