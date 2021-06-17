import 'effect_system.dart';
import '../systems/react_on_system.dart';
import '../types/types.dart';

extension EffectSystemReactOperators<State, Event> on EffectSystem<State, Event> {

  /// State based version of `add(effect: )`.
  /// 
  /// Conceptually, this effect is triggered based on state change.
  /// This is same as `add(effect: )` except it ignored `event` parameter.
  EffectSystem<State, Event> reactState({
    required void Function(State state, State? oldState, Dispatch<Event> dispatch) effect,
  }) => forward(copy: (system) => system.reactState(
    effect: effect
  ));
}