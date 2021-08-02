import '../types/types.dart';
import 'system.dart';

extension OnOperators<State, Event> on System<State, Event> {

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

  /// Add effect on system run.
  /// 
  /// This operator will inject effect when system run,
  /// For example, We can trigger networing call by dispatch a trigger event:
  /// 
  ///```dart 
  ///  ...
  ///  .on<LoadData>(effect: (state, event, dispatch) async {
  ///    try {
  ///      final data = await api.call(state.itemId);
  ///      dispatch(LoadDataSuccess(data));
  ///    } on Exception {
  ///      dispatch(LoadDataError());
  ///    }
  ///  })
  ///  .onRun(effect: (initialState, dispatch) {
  ///     dispatch(LoadData()); 
  ///  },);
  /// ```
  /// 
  /// [effect] can return an optional `Dispose` function.
  /// This can be used when this system has interaction with other service, 
  /// which has listenable API like `Stream`, `ChangeNotifier` or `System`.
  /// With these cases, we can listen to them (`Stream`) when systen run, 
  /// return `Dispose` contains `cancel` logic.
  /// Then `Dispose` will be called, when system dispose get called.
  /// 
  ///```dart 
  ///  ...
  ///  .onRun(effect: (initialState, dispatch) {
  ///    final timer = Stream
  ///      .periodic(Duration(seconds: 1), (it) => it);
  ///    final subscription = timer.listen((it) => dispatch('$it'));
  ///    return Dispose(() => subscription.cancel());
  ///  },);
  /// ```
  /// 
  System<State, Event> onRun({
    required Dispose? Function(State initialState, Dispatch<Event> dispatch) effect,
  }) => withContext<_OnRunContext>(
    createContext: () => _OnRunContext(),
    effect: (context, state, oldState, event, dispatch) {
      if (event == null) {
        context.dispose = effect(state, dispatch);
      }
    },
    dispose: (context) {
      if (context.dispose != null) {
        context.dispose?.call();
        context.dispose = null;
      }
    }
  );
  
  /// Add code block that tied with running system's dispose function.
  System<State, Event> onDispose({
    required void Function() run
  }) => copy((_run) => ({reduce, effect}) {
    final dispose = Dispose(run);
    final sourceDispose = _run(reduce: reduce, effect: effect);
    return Dispose(() {
      sourceDispose();
      dispose();
    });
  });
}

class _OnRunContext{
  Dispose? dispose;
}

Result? _testEvent<Result, ChildEvent, Event>(Event event, {
  required ChildEvent? Function(Event event) test,
  required Result Function(ChildEvent childEvent) then,
}) {
  final childEvent = test(event);
  if (childEvent != null) return then(childEvent);
}

R? _safeAs<T, R>(T value) => value is R ? value : null;