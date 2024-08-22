import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface Card { 'value' : bigint, 'suit' : string }
export interface GameState {
  'playerChips' : bigint,
  'communityCards' : Array<Card>,
  'stage' : string,
  'playerHand' : Array<Card>,
  'currentBet' : bigint,
}
export interface _SERVICE {
  'evaluateHands' : ActorMethod<[], string>,
  'getGameState' : ActorMethod<[], [] | [GameState]>,
  'initGame' : ActorMethod<[], string>,
  'placeBet' : ActorMethod<[bigint], string>,
  'revealCommunityCards' : ActorMethod<[], string>,
  'shuffleDeck' : ActorMethod<[Array<Card>], Array<Card>>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
