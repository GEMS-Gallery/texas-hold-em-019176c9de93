import Bool "mo:base/Bool";
import Text "mo:base/Text";

import Array "mo:base/Array";
import Random "mo:base/Random";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Buffer "mo:base/Buffer";
import Blob "mo:base/Blob";

actor TexasHoldem {
  type Card = {
    suit: Text;
    value: Nat;
  };

  type GameState = {
    playerHand: [Card];
    communityCards: [Card];
    playerChips: Nat;
    currentBet: Nat;
    stage: Text;
  };

  stable var playerChips: Nat = 1000;
  var currentGame: ?GameState = null;
  var deck: [Card] = [];

  func createDeck(): [Card] {
    let suits = ["Hearts", "Diamonds", "Clubs", "Spades"];
    let values = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]; // 11 = Jack, 12 = Queen, 13 = King, 14 = Ace
    var newDeck: Buffer.Buffer<Card> = Buffer.Buffer(52);

    for (suit in suits.vals()) {
      for (value in values.vals()) {
        newDeck.add({ suit = suit; value = value });
      };
    };

    Buffer.toArray(newDeck)
  };

  public func shuffleDeck(deck: [Card]): async [Card] {
    let shuffled = Array.thaw<Card>(deck);
    let size = deck.size();

    for (i in Iter.range(0, size - 1)) {
      let randomBytes = await Random.blob();
      let randomArray = Blob.toArray(randomBytes);
      let j = Nat8.toNat(randomArray[0] % Nat8.fromNat(size));
      let temp = shuffled[i];
      shuffled[i] := shuffled[j];
      shuffled[j] := temp;
    };

    Array.freeze(shuffled)
  };

  public func initGame(): async Text {
    deck := await shuffleDeck(createDeck());
    let playerHand = [deck[0], deck[1]];
    let communityCards: [Card] = [];

    currentGame := ?{
      playerHand = playerHand;
      communityCards = communityCards;
      playerChips = playerChips;
      currentBet = 0;
      stage = "preflop";
    };

    "Game initialized. Your hand: " # cardToString(playerHand[0]) # ", " # cardToString(playerHand[1])
  };

  public func placeBet(amount: Nat): async Text {
    switch (currentGame) {
      case (null) { return "No active game. Please initialize a game first." };
      case (?game) {
        if (amount > game.playerChips) {
          return "Insufficient chips. You only have " # Nat.toText(game.playerChips) # " chips.";
        };

        let updatedChips = game.playerChips - amount;
        let updatedBet = game.currentBet + amount;

        currentGame := ?{
          playerHand = game.playerHand;
          communityCards = game.communityCards;
          playerChips = updatedChips;
          currentBet = updatedBet;
          stage = game.stage;
        };

        playerChips := updatedChips;

        "Bet placed. Current bet: " # Nat.toText(updatedBet) # ", Remaining chips: " # Nat.toText(updatedChips)
      };
    }
  };

  public func revealCommunityCards(): async Text {
    switch (currentGame) {
      case (null) { return "No active game. Please initialize a game first." };
      case (?game) {
        var newCommunityCards = game.communityCards;
        var newStage = game.stage;
        var newlyRevealed: [Card] = [];

        switch (game.stage) {
          case ("preflop") {
            newlyRevealed := [deck[2], deck[3], deck[4]];
            newCommunityCards := Array.append(newCommunityCards, newlyRevealed);
            newStage := "flop";
          };
          case ("flop") {
            newlyRevealed := [deck[5]];
            newCommunityCards := Array.append(newCommunityCards, newlyRevealed);
            newStage := "turn";
          };
          case ("turn") {
            newlyRevealed := [deck[6]];
            newCommunityCards := Array.append(newCommunityCards, newlyRevealed);
            newStage := "river";
          };
          case (_) { return "All community cards have been revealed." };
        };

        currentGame := ?{
          playerHand = game.playerHand;
          communityCards = newCommunityCards;
          playerChips = game.playerChips;
          currentBet = game.currentBet;
          stage = newStage;
        };

        "Newly revealed cards: " # cardsToString(newlyRevealed) # "\nAll community cards: " # cardsToString(newCommunityCards)
      };
    }
  };

  public func evaluateHands(): async Text {
    switch (currentGame) {
      case (null) { return "No active game. Please initialize a game first." };
      case (?game) {
        if (game.stage != "river") {
          return "Cannot evaluate hands until all community cards are revealed.";
        };

        let playerScore = evaluateHand(Array.append(game.playerHand, game.communityCards));
        let opponentHand = [deck[7], deck[8]];
        let opponentScore = evaluateHand(Array.append(opponentHand, game.communityCards));

        let result = if (playerScore > opponentScore) {
          "You win! Your hand: " # handRankToString(playerScore)
        } else if (playerScore < opponentScore) {
          "You lose. Opponent's hand: " # handRankToString(opponentScore)
        } else {
          "It's a tie! Both hands: " # handRankToString(playerScore)
        };

        currentGame := null;
        result
      };
    }
  };

  public query func getGameState(): async ?GameState {
    currentGame
  };

  func evaluateHand(hand: [Card]): Nat {
    // This is a simplified hand evaluation.
    // In a real implementation, you'd need a more sophisticated algorithm.
    let values = Array.map<Card, Nat>(hand, func(card: Card): Nat { card.value });
    let sortedValues = Array.sort(values, Nat.compare);
    let uniqueValues = Array.size(Array.filter<Nat>(sortedValues, func(v: Nat): Bool { v != sortedValues[0] }));

    if (uniqueValues == 2) {
      7 // Four of a kind or Full house
    } else if (uniqueValues == 3) {
      4 // Three of a kind or Two pair
    } else if (uniqueValues == 4) {
      2 // One pair
    } else {
      1 // High card
    }
  };

  func cardToString(card: Card): Text {
    let valueStr = switch (card.value) {
      case (11) { "Jack" };
      case (12) { "Queen" };
      case (13) { "King" };
      case (14) { "Ace" };
      case (n) { Nat.toText(n) };
    };
    valueStr # " of " # card.suit
  };

  func cardsToString(cards: [Card]): Text {
    Array.foldLeft<Card, Text>(cards, "", func(acc, card) {
      if (acc == "") { cardToString(card) } else { acc # ", " # cardToString(card) }
    })
  };

  func handRankToString(rank: Nat): Text {
    switch (rank) {
      case (7) { "Four of a kind or Full house" };
      case (4) { "Three of a kind or Two pair" };
      case (2) { "One pair" };
      case (1) { "High card" };
      case (_) { "Unknown hand" };
    }
  };
}
