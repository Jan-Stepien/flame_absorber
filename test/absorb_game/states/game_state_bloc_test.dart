import 'package:absorb/absorb_game/states/game_state.dart';
import 'package:absorb/absorb_game/states/game_state_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameStateBloc', () {
    test('initial state is correct', () {
      final bloc = GameStateBloc();
      expect(bloc.state, equals(GameState.initial));
      expect(bloc.state.score, equals(0));
      expect(bloc.state.lives, equals(3));
      expect(bloc.state.status, equals(GameStatus.start));
      bloc.close();
    });

    blocTest<GameStateBloc, GameState>(
      'StartGame transitions to playing status',
      build: GameStateBloc.new,
      act: (bloc) => bloc.add(const StartGame()),
      expect: () => [
        const GameState(score: 0, lives: 3, status: GameStatus.playing),
      ],
    );

    blocTest<GameStateBloc, GameState>(
      'GoodBallAbsorbed increases score by 10',
      build: GameStateBloc.new,
      seed: () => const GameState(score: 0, lives: 3, status: GameStatus.playing),
      act: (bloc) => bloc.add(const GoodBallAbsorbed()),
      expect: () => [
        const GameState(score: 10, lives: 3, status: GameStatus.playing),
      ],
    );

    blocTest<GameStateBloc, GameState>(
      'multiple GoodBallAbsorbed events accumulate score',
      build: GameStateBloc.new,
      seed: () => const GameState(score: 0, lives: 3, status: GameStatus.playing),
      act: (bloc) {
        bloc.add(const GoodBallAbsorbed());
        bloc.add(const GoodBallAbsorbed());
        bloc.add(const GoodBallAbsorbed());
      },
      expect: () => [
        const GameState(score: 10, lives: 3, status: GameStatus.playing),
        const GameState(score: 20, lives: 3, status: GameStatus.playing),
        const GameState(score: 30, lives: 3, status: GameStatus.playing),
      ],
    );

    blocTest<GameStateBloc, GameState>(
      'BadBallAbsorbed decreases lives by 1',
      build: GameStateBloc.new,
      seed: () => const GameState(score: 0, lives: 3, status: GameStatus.playing),
      act: (bloc) => bloc.add(const BadBallAbsorbed()),
      expect: () => [
        const GameState(score: 0, lives: 2, status: GameStatus.playing),
      ],
    );

    blocTest<GameStateBloc, GameState>(
      'BadBallAbsorbed triggers game over when lives reach 0',
      build: GameStateBloc.new,
      seed: () => const GameState(score: 0, lives: 3, status: GameStatus.playing),
      act: (bloc) {
        bloc.add(const BadBallAbsorbed());
        bloc.add(const BadBallAbsorbed());
        bloc.add(const BadBallAbsorbed());
      },
      expect: () => [
        const GameState(score: 0, lives: 2, status: GameStatus.playing),
        const GameState(score: 0, lives: 1, status: GameStatus.playing),
        const GameState(score: 0, lives: 0, status: GameStatus.gameOver),
      ],
    );

    blocTest<GameStateBloc, GameState>(
      'events are ignored when game is over',
      build: GameStateBloc.new,
      seed: () => const GameState(score: 0, lives: 0, status: GameStatus.gameOver),
      act: (bloc) {
        bloc.add(const GoodBallAbsorbed());
        bloc.add(const BadBallAbsorbed());
      },
      expect: () => <GameState>[],
    );

    blocTest<GameStateBloc, GameState>(
      'ResetGame resets to playing state with initial values',
      build: GameStateBloc.new,
      seed: () => const GameState(score: 20, lives: 2, status: GameStatus.playing),
      act: (bloc) => bloc.add(const ResetGame()),
      expect: () => [
        const GameState(score: 0, lives: 3, status: GameStatus.playing),
      ],
    );

    blocTest<GameStateBloc, GameState>(
      'score and lives work together correctly',
      build: GameStateBloc.new,
      seed: () => const GameState(score: 0, lives: 3, status: GameStatus.playing),
      act: (bloc) {
        bloc.add(const GoodBallAbsorbed());
        bloc.add(const BadBallAbsorbed());
        bloc.add(const GoodBallAbsorbed());
        bloc.add(const GoodBallAbsorbed());
        bloc.add(const BadBallAbsorbed());
      },
      expect: () => [
        const GameState(score: 10, lives: 3, status: GameStatus.playing),
        const GameState(score: 10, lives: 2, status: GameStatus.playing),
        const GameState(score: 20, lives: 2, status: GameStatus.playing),
        const GameState(score: 30, lives: 2, status: GameStatus.playing),
        const GameState(score: 30, lives: 1, status: GameStatus.playing),
      ],
    );
  });
}
