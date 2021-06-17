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

  /// Add `effect` triggered by react partial state value change.
  /// 
  /// [value] describe which part of value is observed.
  /// 
  /// [areEqual] describe how old value and new value are treat as equal (not change).
  /// 
  /// [skipFirstValue] is false if first value will trigger the effect, 
  /// is ture if first value won't trigger effect, default is false.  
  ///
  /// [effect] describe side effect. 
  EffectSystem<State, Event> react<Value>({
    required Value Function(State state) value,
    AreEqual<Value>? areEqual,
    bool skipFirstValue = false,
    required void Function(Value value, Dispatch<Event> dispatch) effect,
  }) => forward(copy: (system) => system.react(
    value: value,
    areEqual: areEqual,
    skipFirstValue: skipFirstValue,
    effect: effect,
  ));
}