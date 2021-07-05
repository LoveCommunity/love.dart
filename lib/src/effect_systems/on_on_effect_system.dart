import 'effect_system.dart';
import '../types/types.dart';
import '../systems/on_on_system.dart';

extension EffectSystemOnOperators<State, Event> on EffectSystem<State, Event> {

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
  EffectSystem<State, Event> onLatest<ChildEvent>({
    ChildEvent? Function(Event event)? test,
    required Dispose? Function(State state, ChildEvent event, Dispatch<Event> dispatch) effect,
  }) => forward(copy: (system) => system.onLatest(
    test: test,
    effect: effect
  ));

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
  EffectSystem<State, Event> onRun({
    required Dispose? Function(State initialState, Dispatch<Event> dispatch) effect,
  }) => forward(copy: (system) => system.onRun(
    effect: effect,
  ));
  
  /// Add code block that tied with running system's dispose function.
  EffectSystem<State, Event> onDispose({
    required void Function() run
  }) => forward(copy: (system) => system.onDispose(
    run: run,
  ));
}