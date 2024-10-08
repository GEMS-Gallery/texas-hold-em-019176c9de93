export const idlFactory = ({ IDL }) => {
  const Card = IDL.Record({ 'value' : IDL.Nat, 'suit' : IDL.Text });
  const GameState = IDL.Record({
    'playerChips' : IDL.Nat,
    'communityCards' : IDL.Vec(Card),
    'stage' : IDL.Text,
    'playerHand' : IDL.Vec(Card),
    'currentBet' : IDL.Nat,
  });
  return IDL.Service({
    'evaluateHands' : IDL.Func([], [IDL.Text], []),
    'getGameState' : IDL.Func([], [IDL.Opt(GameState)], ['query']),
    'initGame' : IDL.Func([], [IDL.Text], []),
    'placeBet' : IDL.Func([IDL.Nat], [IDL.Text], []),
    'revealCommunityCards' : IDL.Func([], [IDL.Text], []),
    'shuffleDeck' : IDL.Func([IDL.Vec(Card)], [IDL.Vec(Card)], []),
  });
};
export const init = ({ IDL }) => { return []; };
