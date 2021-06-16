import 'system.dart';
import '../types/types.dart';

extension ReactOperators<State, Event> on System<State, Event> {

  /// State based version of `add(effect: )`.
  /// 
  /// Conceptually, this effect is triggered based on state change.
  /// This is same as `add(effect: )` except it ignored `event` parameter.
  System<State, Event> reactState({
    required void Function(State state, State? oldState, Dispatch<Event> dispatch) effect,
  }) => add(
    effect: (state, oldState, event, dispatch) {
      effect(state, oldState, dispatch);
    }
  );
}