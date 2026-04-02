import 'package:flutter_bloc/flutter_bloc.dart';

import 'game_state.dart';

sealed class GameStateEvent {
  const GameStateEvent();
}

final class StartGame extends GameStateEvent {
  const StartGame();
}

final class ResetGame extends GameStateEvent {
  const ResetGame();
}

final class GoodBallAbsorbed extends GameStateEvent {
  const GoodBallAbsorbed();
}

final class BadBallAbsorbed extends GameStateEvent {
  const BadBallAbsorbed();
}

class GameStateBloc extends Bloc<GameStateEvent, GameState> {
  static const int _initialLives = 3;
  static const int _goodBallScore = 10;
  static const double _initialAbsorberRadius = 36;
  static const double _goodAbsorbRadiusGrowth = 3;

  GameStateBloc() : super(GameState.initial) {
    on<StartGame>(_onStartGame);
    on<ResetGame>(_onResetGame);
    on<GoodBallAbsorbed>(_onGoodBallAbsorbed);
    on<BadBallAbsorbed>(_onBadBallAbsorbed);
  }

  void _onStartGame(StartGame event, Emitter<GameState> emit) {
    emit(GameState.initial.copyWith(status: GameStatus.playing));
  }

  void _onResetGame(ResetGame event, Emitter<GameState> emit) {
    emit(
      const GameState(
        score: 0,
        lives: _initialLives,
        status: GameStatus.playing,
        absorberRadius: _initialAbsorberRadius,
      ),
    );
  }

  void _onGoodBallAbsorbed(GoodBallAbsorbed event, Emitter<GameState> emit) {
    if (state.status != GameStatus.playing) {
      return;
    }
    emit(
      state.copyWith(
        score: state.score + _goodBallScore,
        absorberRadius: state.absorberRadius + _goodAbsorbRadiusGrowth,
      ),
    );
  }

  void _onBadBallAbsorbed(BadBallAbsorbed event, Emitter<GameState> emit) {
    if (state.status != GameStatus.playing) {
      return;
    }

    final updatedLives = state.lives - 1;
    if (updatedLives <= 0) {
      emit(state.copyWith(lives: 0, status: GameStatus.gameOver));
      return;
    }
    emit(state.copyWith(lives: updatedLives));
  }
}
