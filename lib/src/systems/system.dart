import '../types/types.dart';

class System<State, Event> {

  /// Create a System with underlinying run function.
  /// 
  /// It can be used when we has custom run logic. 
  /// Like Mock `System` that is used for testing purpose.
  System.pure(this._run);

  final Run<State, Event> _run;

  /// Run the system.
  /// 
  /// Return a Dispose function to stop system later.
  Dispose run({
    Reduce<State, Event>? reduce,
    Effect<State, Event>? effect,
  }) {
    var isDisposed = false;
    final dispose = _run(
      reduce: reduce,
      effect: effect,
    );
    return Dispose(() {
      if (isDisposed) return;
      isDisposed = true;
      dispose();
    });
  }

  /// Create a [System] with initail state.
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
}

Run<State, Event> _create<State, Event>({
  required State initialState,
}) => ({reduce, effect}) {
  assert(reduce != null, 'reduce is null when system run!');
  if (reduce == null) return Dispose.nothing();

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

  final dispatch = Dispatch(_dispatch);

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

  return Dispose(() {
    if (isDisposed) return;
    isDisposed = true;
    state = null;
  });
};