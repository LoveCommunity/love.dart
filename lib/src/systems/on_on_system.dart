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

  /// Add `reduce` or `effect` when event meet some condition.
  /// 
  /// [test] is used for testing if event meet some condition, 
  /// return null if it not pass test, return a payload if it pass the test.
  /// If [test] is ommited, it will use safe cast as condition.
  /// 
  /// Note: The event parameter in `reduce` and `effect` are smart casted to the ChildEvent type.
  System<State, Event> on<ChildEvent>({
    ChildEvent? Function(Event event)? test,
    Reduce<State, ChildEvent>? reduce,
    void Function(State state, ChildEvent event, Dispatch<Event> dispatch)? effect,
  }) {
    final _test = test ?? _safeAs;
    return add(
      reduce: reduce == null ? null : (state, event) {
        return _testEvent(event, 
          test: _test, 
          then: (ChildEvent childEvent) => reduce(state, childEvent),
        ) ?? state;
      },
      effect: effect == null ? null : (state, oldState, event, dispatch) {
        if (oldState != null && event != null) {
          _testEvent(event, 
            test: _test, 
            then: (ChildEvent childEvent) => effect(state, childEvent, dispatch),
          );
        }
      },
    );
  }
}

Result? _testEvent<Result, ChildEvent, Event>(Event event, {
  required ChildEvent? Function(Event event) test,
  required Result Function(ChildEvent childEvent) then,
}) {
  final childEvent = test(event);
  if (childEvent != null) return then(childEvent);
}

R? _safeAs<T, R>(T value) => value is R ? value : null;