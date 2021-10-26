import '../utils/utils.dart';
import '../types/types.dart';

typedef CopySystem<State, Event> = System<State, Event> Function(System<State, Event> system);

class System<State, Event> {

  /// Create a System with underlying run function.
  /// 
  /// It can be used when we has custom run logic. 
  /// Like Mock `System` that is used for testing purpose.
  System.pure(this._run);

  final Run<State, Event> _run;

  /// Run the system.
  /// 
  /// Return a Disposer to stop system later.
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
  System.create({
    required State initialState,
  }): this.pure(_create(initialState: initialState));

  /// Create a new system based on current one.
  /// 
  /// Return a redefined system by copy a new one with custom logic.
  /// The concept is similar to `middleware` or `interceptor`.
  System<State, Event> copy(
    CopyRun<State, Event> copy
  ) {
    final next = copy(_run);
    return System.pure(next);
  }

  /// Create a new system with a Context.
  /// 
  /// Return a new system with some "live data" associated with it.
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

  /// Create a new system with a Context.
  /// 
  /// Return a new system with some "live data" associated with it.
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

  /// Add a `reduce` or `effect` to the system.
  /// 
  /// If we adds `reduce` or `effect` multiple times, The call side order is in serial.
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