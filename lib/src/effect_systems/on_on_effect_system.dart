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

  /// Add `effect` when event meet some condition.
  /// 
  /// [test] is used for testing if event meet some condition, 
  /// return null if it not pass test, return a payload if it pass the test.
  /// If [test] is ommited, it will use safe cast as condition.
  /// 
  /// Note: The event parameter `effect` are smart casted to the ChildEvent type.
  EffectSystem<State, Event> on<ChildEvent>({
    ChildEvent? Function(Event event)? test,
    required void Function(State state, ChildEvent event, Dispatch<Event> dispatch) effect, 
  }) => forward(copy: (system) => system.on(
    test: test,
    effect: effect
  ));
}