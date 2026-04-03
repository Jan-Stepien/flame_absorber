import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_state.freezed.dart';

enum GameStatus { start, playing, gameOver }

@freezed
abstract class GameState with _$GameState {
  const factory GameState({
    required int score,
    required int lives,
    required GameStatus status,
  }) = _GameState;

  static const GameState initial = GameState(
    score: 0,
    lives: 3,
    status: GameStatus.start,
  );
}
