import 'system.dart' show System;
import '../types/types.dart' show Dispatch, Disposer, Reduce;
import '../utils/safe_as.dart' show safeAs;

extension OnX<State, Event> on System<State, Event> {

  /// Add `reduce` or `effect` when event meet some condition.
  /// 
  /// ## API Overview
  /// 
  /// ```dart
  /// system
  ///   ...
  ///   .on<SomeEvent>(
  ///     test: (Event event) {       
  ///       return event is SomeEvent // test if we are concerned about this event,
  ///         ? event                 // return `SomeEvent` if we are concerned,
  ///         : null;                 // return null if we are not concerned,
  ///     },                          // `test` is nullable, defaults to safe cast as shown.
  ///     reduce: (state, SomeEvent event) => state // compute a new state based
  ///       .copyWith(                              // on current state and event.
  ///         someField: event.someField,           // `reduce` is nullable.
  ///       ), 
  ///     effect: (state, SomeEvent event, dispatch) async { 
  ///       // trigger effect when `SomeEvent` happen.
  ///       // `effect` is nullable.
  ///     },
  ///   )
  ///   ...
  /// ```  
  /// 
  /// ## Usage Example
  /// 
  /// Below code showed how to add `reduce` and `effect`,
  /// when `Increment` or `Decrement` event happen.
  /// 
  /// ```dart
  /// counterSystem
  ///   ...
  ///   .on<Increment>(
  ///     reduce: (state, event) => state + 1,
  ///     effect: (state, event, dispatch) async {
  ///       await Future<void>.delayed(const Duration(seconds: 3));
  ///       dispatch(Decrement());
  ///     },
  ///   )
  ///   .on<Decrement>(
  ///     reduce: (state, event) => state - 1,
  ///   )
  ///   ...
  /// ```  
  /// 
  /// If `Increment` happen, it will increase counts by 1, and wait 3 seconds
  /// then `dispatch` a `Decrement` event to restore counts.
  /// If `Decrement` happen, it will decrease counts by 1.
  ///
  System<State, Event> on<ChildEvent>({
    ChildEvent? Function(Event event)? test,
    Reduce<State, ChildEvent>? reduce,
    void Function(State state, ChildEvent event, Dispatch<Event> dispatch)? effect,
  }) {
    final _test = test ?? safeAs;
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
  /// For example, We can trigger networking call by dispatch a trigger event:
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
  /// [effect] can return an optional `Disposer`.
  /// This can be used when this system has interaction with other service, 
  /// which has listenable API like `Stream`, `ChangeNotifier` or `System`.
  /// With these cases, we can listen to them (`Stream`) when system run, 
  /// return `Disposer` contains `cancel` logic.
  /// Then `Disposer` will be called, when system disposer get called.
  /// 
  ///```dart 
  ///  ...
  ///  .onRun(effect: (initialState, dispatch) {
  ///    final timer = Stream
  ///      .periodic(const Duration(seconds: 1), (it) => it);
  ///    final subscription = timer.listen((it) => dispatch('$it'));
  ///    return Disposer(() => subscription.cancel());
  ///  },);
  /// ```
  /// 
  System<State, Event> onRun({
    required Disposer? Function(State initialState, Dispatch<Event> dispatch) effect,
  }) => withContext<_OnRunContext>(
    createContext: () => _OnRunContext(),
    effect: (context, state, oldState, event, dispatch) {
      if (event == null) {
        context.disposer = effect(state, dispatch);
      }
    },
    dispose: (context) {
      if (context.disposer != null) {
        context.disposer?.call();
        context.disposer = null;
      }
    }
  );
  
  /// Add code block that tied with running system's disposer.
  ///
  /// It will register a `dispose` callback into system, this callback will
  /// be invoked right after running system dispose.
  /// 
  /// ## Usage Example
  /// 
  /// ```dart
  /// 
  /// final controller = SomeController(); // somewhere within same scope
  /// 
  /// ...
  /// 
  /// system
  ///   ...
  ///   .onDispose(
  ///     run: () => controller.dispose(),
  ///   )
  ///   ...
  /// ```
  /// 
  /// Above code will dispose `controller` if system is disposing.
  /// 
  System<State, Event> onDispose({
    required void Function() run
  }) => copy((_run) => ({reduce, effect, interceptor}) {
    final disposer = Disposer(run);
    final sourceDisposer = _run(reduce: reduce, effect: effect, interceptor: interceptor);
    return Disposer(() {
      sourceDisposer();
      disposer();
    });
  });
}

class _OnRunContext{
  Disposer? disposer;
}

Result? _testEvent<Result, ChildEvent, Event>(Event event, {
  required ChildEvent? Function(Event event) test,
  required Result Function(ChildEvent childEvent) then,
}) {
  final childEvent = test(event);
  if (childEvent != null) return then(childEvent);
}

