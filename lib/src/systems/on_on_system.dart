import '../types/types.dart';
import 'system.dart';

extension OnOperators<State, Event> on System<State, Event> {

  /// Event based version of `add(effect: )`.
  /// 
  /// Conceptually, this effect is triggered based on event.
  /// This is same as `add(effect: )` except it ignored `oldState` parameter.
  System<State, Event> onEvent({
    required void Function(State state, Event? event, Dispatch<Event> dispatch) effect,
  }) => add(
    effect: (state, oldState, event, dispatch) {
      effect(state, event, dispatch);
    }
  );
}