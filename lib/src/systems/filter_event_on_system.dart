import 'system.dart';
import '../types/types.dart';
import '../utils/utils.dart';

typedef EventInterceptor<Context, Event> = void Function(Context context, Dispatch<Event> dispatch, Event event);

extension FilterEventOperators<State, Event> on System<State, Event> {

  System<State, Event> eventInterceptor<Context>({
    required Context Function() createContext,
    ContextEffect<Context, State, Event>? updateContext,
    required EventInterceptor<Context, Event> interceptor,
    void Function(Context context)? dispose,
  }) {
    return runWithContext<_EventInterceptorContext<Context, Event>>(
      createContext: () => _EventInterceptorContext(
        childContext: createContext(),
      ),
      run: (context, run, nextReduce, nextEffect) {
        final Effect<State, Event>? effect = _eventInterceptorEffect(
          context: context,
          updateContext: updateContext,
          nextEffect: nextEffect,
          interceptor: interceptor
        );
        final sourceDispose = run(
          reduce: nextReduce,
          effect: effect,
        );
        return Dispose(() {
          context.isDisposed = true;
          dispose?.call(context.childContext);
          sourceDispose();
        });
      },
    );
  }
}

Effect<State, Event>? _eventInterceptorEffect<Context, State, Event>({
  required _EventInterceptorContext<Context, Event> context,
  required ContextEffect<Context, State, Event>? updateContext,
  required Effect<State, Event>? nextEffect,
  required EventInterceptor<Context, Event> interceptor,
}) {
  if (nextEffect == null) return null;
  final Effect<State, Event>? _updateContextEffect = updateContext == null ? null : (state, oldState, event, dispatch) {
    updateContext(context.childContext, state, oldState, event, dispatch);
  };
  final Effect<State, Event> _nextEffect = (state, oldState, event, dispatch) {
    final Dispatch<Event> nextDispatch = context.nextDispatch(
      dispatch: dispatch,
      interceptor: interceptor,
    );
    nextEffect(state, oldState, event, nextDispatch);
  };
  return combineEffect(
    _updateContextEffect,
    _nextEffect,
  );
}

class _EventInterceptorContext<ChildContext, Event> {

  _EventInterceptorContext({
    required this.childContext,
  });

  final ChildContext childContext;

  bool isDisposed = false;
  Dispatch<Event>? _dispatch;
  Dispatch<Event>? _nextDispatch;

  Dispatch<Event> nextDispatch({
    required Dispatch<Event> dispatch,
    required EventInterceptor<ChildContext, Event> interceptor,
  }) {
    if (_nextDispatch != null && identical(_dispatch, dispatch)) return _nextDispatch!;
    _dispatch = dispatch;
    _nextDispatch = Dispatch((event) {
      if (isDisposed) return;
      interceptor(childContext, dispatch, event);
    });
    return _nextDispatch!;
  }
}