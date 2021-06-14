import '../types/types.dart';
import '../types/latest_context.dart';
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

  ///  Add `effect` when event meet some condition which will cancel previous effect when a new conditional event came.
  ///
  /// [test] is used for testing if event meet some condition, 
  /// return null if it not pass test, return a payload if it pass the test. 
  /// If [test] is ommited, it will use safe cast as condition. 
  ///
  /// It's useful for scenario like search bar. 
  /// latest search words cancel prevoius search api if previous one is not completed.
  /// 
  /// ```dart
  /// .onLatest<TriggerSearch>(
  ///   effect: (state, event, dispatch) async {
  ///     try {
  ///       final data = await api.call(event.keyword);
  ///       dispatch(LoadDataSuccess(data));
  ///     } on Exception {
  ///       dispatch(LoadDataError());
  ///     }
  ///   },
  /// )
  /// ```
  /// 
  /// For this scenario if previous search result came after latest one, 
  /// the result will be ignored.
  /// 
  /// If search `api` provide a cancellation mechanism, 
  /// We can return a `Dispose` function contain the cancellation logic in effect callback.
  /// 
  /// For example if above `api.call` return `Stream` instead of `Future`:
  /// 
  /// ```dart
  /// .onLatest<TriggerSearch>(
  ///   effect: (state, event, dispatch) {
  ///     final stream = api.call(event.keyword);
  ///     final subscription = stream.listen(
  ///       (data) => dispatch(LoadDataSuccess(data)),
  ///       onError: (Object _) => dispatch(LoadDataError()),
  ///     );
  ///     return Dispose(() => subscription.cancel());
  ///   },
  /// )
  /// ```
  /// 
  /// This `Dispose` will be called when next conditional event happen or system dispose is called.
  /// 
  System<State, Event> onLatest<ChildEvent>({
    ChildEvent? Function(Event event)? test,
    required Dispose? Function(State state, ChildEvent event, Dispatch<Event> dispatch) effect,
  }) {
    final _test = test ?? _safeAs;
    return withContext<LatestContext<Event>>(
      createContext: () => LatestContext(),
      effect: (context, state, oldState, event, dispatch) {
        if (event != null) {
          _testEvent(event,
            test: _test,
            then: (ChildEvent childEvent) {
              context.disposePreviousEffect();
              context.dispose = effect(state, childEvent, context.versioned(dispatch));
            },
          );
        }
      },
      dispose: (context) => context.disposePreviousEffect(),
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