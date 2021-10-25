
/// Describe the equality of two item
typedef Equals<T> = bool Function(T it1, T it2);
bool defaultEquals<T>(T it1, T it2) => it1 == it2;

/// Describe how state update when event come
typedef Reduce<State, Event> = State Function(State state, Event event);

/// Describe how to intercept event
typedef Interceptor<Event> = Dispatch<Event> Function(Dispatch<Event> dispatch);

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
/// Describe how side effect are performed with a context.
typedef ContextEffect<Context, State, Event> = void Function(Context context, State state, State? oldState, Event? event, Dispatch<Event> dispatch);

/// Describe how resources are cleaned
class Disposer {
  Disposer(this._func);
  final void Function() _func;
  void call() => _func();
  Disposer.nothing(): this(() {});
}

typedef Run<State, Event> = Disposer Function({
  Reduce<State, Event>? reduce,
  Effect<State, Event>? effect,
  Interceptor<Event>? interceptor,
});

typedef CopyRun<State, Event> = Run<State, Event> Function(Run<State, Event> run);

/// A holder of state, oldState and event of a moment
class Moment<State, Event> {
  final State state;
  final State? oldState;
  final Event? event;
  const Moment(this.state, this.oldState, this.event);
}