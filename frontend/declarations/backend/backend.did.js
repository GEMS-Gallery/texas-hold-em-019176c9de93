export const idlFactory = ({ IDL }) => {
  const Card = IDL.Record({ 'value' : IDL.Nat, 'suit' : IDL.Text });
  return IDL.Service({
    'evaluateHands' : IDL.Func([], [IDL.Text], []),
    'initGame' : IDL.Func([], [IDL.Text], []),
    'placeBet' : IDL.Func([IDL.Nat], [IDL.Text], []),
    'revealCommunityCards' : IDL.Func([], [IDL.Text], []),
    'shuffleDeck' : IDL.Func([IDL.Vec(Card)], [IDL.Vec(Card)], []),
  });
};
export const init = ({ IDL }) => { return []; };
