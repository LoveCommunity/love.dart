import '../utils/combine.dart'
  show combineEffect, combineReduce;
import '../types/types.dart' 
  show Effect, Consume, ContextEffect, CopyRun, Dispatch, Disposer, Interceptor, Reduce, Run;

class System<State, Event> {

  /// Create a System with underlying run function.
  /// 
  /// It can be used when we has custom run logic. 
  /// Like Mock `System` that is used for testing purpose.
  System.pure(this._run);

  final Run<State, Event> _run;

  /// Run the system.
  /// 
  /// System dose nothing until run is called.
  /// After `run` get called a `Disposer` is return to stop system later: 
  /// 
  /// ```dart
  /// final disposer = counterSystem.run(); // <- run the system
  /// 
  /// await Future<void>.delayed(const Duration(seconds: 6)); 
  /// 
  /// disposer(); // <- stop the system
  /// ```
  /// 
  /// Optionally, We can provide additional `reduce` and `effect` when system run:
  /// 
  /// ```dart
  /// final dispose = counterSystem.run(
  ///   reduce: (state, event) { ... },
  ///   effect: (state, oldState, event, dispatch) { ... },
  /// );
  /// ```
  /// 
  /// It has same behavior as this:
  /// 
  /// ```dart
  /// final dispose = counterSystem
  ///   .add(
  ///     reduce: (state, event) { ... },
  ///     effect: (state, oldState, event, dispatch) { ... },
  ///   )
  ///   .run();
  /// ```
  /// 
  Disposer run({
    Reduce<State, Event>? reduce,
    Effect<State, Event>? effect,
  }) {
    var isDisposed = false;
    final disposer = _run(
      reduce: reduce,
      effect: effect,
      interceptor: null,
    );
    return Disposer(() {
      if (isDisposed) return;
      isDisposed = true;
      disposer();
    });
  }

  /// Create a [System] with initial state.
  /// 
  /// Create a [System] with initial state seeded into the system:
  /// 
  /// ```dart 
  /// final counterSystem = System<int, CounterEvent>
  ///   .create(initialState: 0) // <- create a counter system
  ///                            // with initial counts 0
  ///   ...;
  /// ```
  ///
  System.create({
    required State initialState,
  }): this.pure(_create(initialState: initialState));

  /// Create a new system based on current one.
  /// 
  /// Return a redefined system by copy a new one with custom logic.
  /// The concept is similar to `middleware` or `interceptor`.
  /// 
  /// This is a low level operator, we can use it to supporting other operators
  /// like `runWithContext`, `onDispose`.
  /// 
  /// ## API Overview
  /// 
  /// ```dart
  /// system
  ///   .copy((run) => ({reduce, effect, interceptor}) {
  ///     final _reduce = _redefineReduce(reduce); // redefine reduce if needed
  ///     final _effect = _redefineEffect(effect); // redefine effect if needed
  ///     final _interceptor = _redefineInterceptor(interceptor); // redefine interceptor if needed
  ///     final disposer = run(reduce: _reduce, effect: _effect, interceptor: _interceptor);
  ///     final _disposer = _redefineDisposer(disposer) // redefine disposer if needed
  ///     return _disposer;
  ///   })
  ///   ...
  /// ```
  /// 
  /// ## Usage Example
  /// 
  /// Bellow code showed how to create an operator `onDispose` 
  /// which register a `dispose` callback into system
  /// 
  /// ```dart
  /// System<State, Event> onDispose({
  ///   required void Function() run
  /// }) => copy((_run) => ({reduce, effect, interceptor}) {
  ///   final disposer = Disposer(run);
  ///   final sourceDisposer = _run(reduce: reduce, effect: effect, interceptor: interceptor);
  ///   return Disposer(() {
  ///     sourceDisposer();
  ///     disposer();
  ///   });
  /// });
  /// ```
  /// 
  /// It redefined the `disposer` and register the `dispose` callback
  /// 
  /// Usage of `system.onDispose`:
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
  System<State, Event> copy(
    CopyRun<State, Event> copy
  ) {
    final next = copy(_run);
    return System.pure(next);
  }

  /// Create a new system which can redefine how to run the system with a custom context.
  /// 
  /// This is a low level operator which can redefine how to run the system,
  /// It has ability to create a custom context associating it with the system,
  /// With a dispose callback to clean up the context.
  /// 
  /// It can be used for supporting other operator like `system.eventInterceptor` 
  /// and `system.runWithContext`.
  /// 
  /// ## API Overview
  /// 
  /// ```dart
  /// 
  /// class SomeContext { ... }
  /// 
  /// ...
  /// 
  /// system
  ///  .runWithContext<SomeContext>(
  ///    createContext: () => SomeContext(), // create context here
  ///    run: (context, run, nextReduce, nextEffect, nextInterceptor) {
  ///      final effect = _redefineEffect(context, nextEffect);    // redefine next effect if needed
  ///      final interceptor = _redefineInterceptor(context, nextInterceptor); // redefine interceptor if needed
  ///      final _run = _redefineRun(context, run);                // redefine run if needed
  ///      final disposer = _run(reduce: nextReduce, effect: effect, interceptor: interceptor);
  ///      final _disposer = _redefineDisposer(context, disposer); // redefine disposer if needed
  ///      return _disposer;
  ///    },
  ///    dispose: (context) {
  ///      // dispose the context if needed.
  ///    }
  ///  )
  ///  ...
  /// ```
  System<State, Event> runWithContext<Context>({
    required Context Function() createContext,
    required Disposer Function(
      Context context, Run<State, Event> run, 
      Reduce<State, Event>? nextReduce, 
      Effect<State, Event>? nextEffect, 
      Interceptor<Event>? nextInterceptor
    ) run,
    void Function(Context context)? dispose,
  }) {
    final _run = run;
    return copy((run) => ({reduce, effect, interceptor}) {
      final context = createContext();
      final sourceDisposer = _run(context, run, reduce, effect, interceptor);
      final combinedDisposer = dispose == null ? sourceDisposer : Disposer(() {
        dispose(context);
        sourceDisposer();
      });
      return combinedDisposer;
    });
  }

  /// Adds `reduce` or `effect` into the system with a custom context.
  /// 
  /// This operator is an enhanced version of [system.add], it would create a custom context
  /// when system run, we can access this context with effect callback.
  /// When system dispose, we can do clean up with it.
  /// 
  /// ## Usage Example
  ///
  /// Bellow code showed how to register service when system run,
  /// and unregister it when system dispose:
  /// 
  /// ```dart
  /// 
  /// class DisposerContext {
  ///   
  ///   Disposer? disposer;
  /// }
  /// 
  /// ...
  /// 
  /// system
  ///   .withContext<DisposerContext>(
  ///     createContext: () => DisposerContext(),
  ///     effect: (context, state, oldState, event, dispatch) {
  ///       if (event == null) { // event is null when system run
  ///         final Stream<User> stream = firebaseService.currentUser;
  ///         final subscription = stream.listen((user) {
  ///           dispatch(UpdateUser(user));
  ///         });
  ///         context.disposer = Disposer(() {
  ///           subscription.cancel();     
  ///         });
  ///       }
  ///     },
  ///     dispose: (context) {
  ///       if (context.disposer != null) {
  ///         context.disposer?.call();        
  ///         context.disposer = null;        
  ///       }
  ///     }
  ///   )
  ///   ...
  /// ```
  /// 
  System<State, Event> withContext<Context>({
    required Context Function() createContext,
    Reduce<State, Event>? reduce,
    ContextEffect<Context, State, Event>? effect,
    void Function(Context context)? dispose,
  }) => runWithContext<Context>(
    createContext: createContext,
    run: (context, run, nextReduce, nextEffect, nextInterceptor) {
      final Effect<State, Event>? _effect = effect == null ? null : (state, oldState, event, dispatch) {
        effect(context, state, oldState, event, dispatch);
      };
      return run(
        reduce: combineReduce(reduce, nextReduce),
        effect: combineEffect(_effect, nextEffect),
        interceptor: nextInterceptor,
      );
    },
    dispose: dispose,
  );

  /// Adds `reduce` or `effect` into the system.
  /// 
  /// If we adds `reduce` or `effect` multiple times, the call side order is in serial.
  /// 
  /// ## Usage Example
  /// 
  /// Bellow code showed how adds `reduce` or `effect` into system: 
  /// 
  /// ```dart
  /// counterSystem
  ///   ...
  ///   .add(reduce: (state, event) {
  ///     if (event is Increment) return state + 1;
  ///     return state;
  ///   })
  ///   .add(reduce: (state, event) {
  ///     if (event is Decrement) return state - 1;
  ///     return state;
  ///   })
  ///   .add(effect: (state, oldState, event, dispatch) {
  ///     // effect - log update
  ///     print('\nEvent: $event');
  ///     print('OldState: $oldState');
  ///     print('State: $state');
  ///   })
  ///   ...
  /// ``` 
  /// 
  System<State, Event> add({
    Reduce<State, Event>? reduce,
    Effect<State, Event>? effect,
  }) => withContext<Null>(
    createContext: () => null,
    reduce: reduce,
    effect: effect == null ? null : (context, state, oldState, event, dispatch) {
      effect(state, oldState, event, dispatch);
    }
  );
}

Run<State, Event> _create<State, Event>({
  required State initialState,
}) => ({reduce, effect, interceptor}) {
  assert(reduce != null, 'reduce is null when system run!');
  if (reduce == null) return Disposer.nothing();

  State? state;
  bool isDisposed = false;
  bool consuming = false;

  late Consume<Event> consume;

  void _dispatch(Event event) {
    if (isDisposed) return;
    if (!consuming) {
      consume(event);
    } else {
      Future(() => _dispatch(event));
    }
  }

  final Dispatch<Event> dispatch = () {
    final rootDispatch = Dispatch(_dispatch);
    return interceptor == null ? rootDispatch : interceptor(rootDispatch);
  }();

  consume = (Event? event) {
    consuming = true;
    final oldState = state;
    final _state = oldState != null && event != null
      ? reduce(oldState, event)
      : initialState;
    state = _state;
    effect?.call(_state, oldState, event, dispatch);
    consuming = false;
  };

  consume(null); // initial event

  return Disposer(() {
    if (isDisposed) return;
    isDisposed = true;
    state = null;
  });
};