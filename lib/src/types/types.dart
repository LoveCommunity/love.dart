

/// Describe how state update when event come
typedef Reduce<State, Event> = State Function(State state, Event event);

typedef DispatchFunc<Event> = void Function(Event event);

/// Send event 
class Dispatch<Event> {
  Dispatch(this._func);
  final DispatchFunc<Event> _func;
  void call(Event event) => _func(event);
}

typedef Consume<Event> = void Function(Event? event);

/// Describe how side effect are performed
typedef Effect<State, Event> = void Function(State state, State? oldState, Event? event, Dispatch<Event> dispatch);

typedef DisposeFunc = void Function();

/// Describe how resources are cleaned
class Dispose {
  Dispose(this._func);
  final DisposeFunc _func;
  void call() => _func();
  Dispose.nothing(): this(() {});
}

typedef Run<State, Event> = Dispose Function({
  Reduce<State, Event>? reduce,
  Effect<State, Event>? effect,
});

typedef CopyRun<State, Event> = Run<State, Event> Function(Run<State, Event> run);