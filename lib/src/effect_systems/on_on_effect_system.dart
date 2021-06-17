import 'effect_system.dart';
import '../types/types.dart';
import '../systems/on_on_system.dart';

extension EffectSystemOnOperators<State, Event> on EffectSystem<State, Event> {

  /// Event based version of `add(effect: )`.
  /// 
  /// Conceptually, this effect is triggered based on event.
  /// This is same as `add(effect: )` except it ignored `oldState` parameter.
  EffectSystem<State, Event> onEvent({
    required void Function(State state, Event? event, Dispatch<Event> dispatch) effect,
  }) => forward(copy: (system) => system.onEvent(
    effect: effect
  ));
}