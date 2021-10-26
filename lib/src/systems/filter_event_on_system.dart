import 'system.dart';
import '../types/types.dart';
import '../utils/utils.dart';

/// An event interceptor with a context associated with it
typedef InterceptorWithContext<Context, Event> = void Function(Context context, Dispatch<Event> dispatch, Event event);

extension FilterEventOperators<State, Event> on System<State, Event> {

  /// Ignore event based on current state and candidate event.
  /// 
  /// ## Usage Example
  /// 
  /// ```dart
  /// futureSystem
  ///   .ignoreEvent(
  ///     when: (state, event) => event is TriggerLoadData && state.loading
  ///   ) 
  ///   ...
  /// ```
  /// 
  /// Above code shown if the system is already in loading status, 
  /// then upcoming `TriggerLoadData` event will be ignored.
  /// 
  /// ## API Overview
  /// 
  /// This operator will intercept candidate event if condition is met.
  /// 
  /// ```dart
  /// system
  ///   .ignoreEvent(
  ///     when: (state, event) { // --> describe if candidate event should be ignored
  ///       // `state` is current state
  ///       // `event` is candidate event
  ///       // return true if we ignore the event
  ///       // return false if we pass the event
  ///       ...
  ///     }
  ///   )
  ///   ...
  /// ```
  /// 
  System<State, Event> ignoreEvent({
    required bool Function(State state, Event event) when,
  }) => eventInterceptor<_IgnoreEventContext<State>>(
    createContext: () => _IgnoreEventContext(),
    updateContext: (context, state, oldState, event, dispatch) {
      context.state = state;
    },
    interceptor: (context, dispatch, event) {
      final shouldIgnoreEvent = when(context.state, event);
      if (!shouldIgnoreEvent) {
        dispatch(event);
      }
    }
  );


  /// Drop conditional events when they are dispatched in high frequency.
  /// 
  /// It's similar to [Rx.observable.debounce](http://reactivex.io/documentation/operators/debounce.html)
  /// 
  /// ## Usage Example
  /// 
  /// ```dart
  /// searchSystem
  ///   ...
  ///   .on<UpdateKeyword>(
  ///     reduce: (state, event) => state.copyWith(keyword: event.keyword)
  ///   )
  ///   .debounceOn<UpdateKeyword>(
  ///     duration: const Duration(seconds: 1)
  ///   )
  ///   ...
  /// ```
  /// 
  /// Above code shown if `UpdateKeyword` event is dispatched with high frequency (quick typing), 
  /// system will drop these events to reduce unnecessary dispatching, 
  /// it will pass (not drop) event if 1 second has passed without dispatch another `UpdateKeyword` event.
  ///
  /// ## API Overview
  /// 
  /// This operator will drop candidate event if condition is met and these events are dispatched with high frequency.
  /// 
  /// ```dart
  /// system
  ///   .debounceOn<ChildEvent>(
  ///     test: (event) { // -> test if we are concern about this event, this parameter is optional,
  ///                     // if `test` is omitted, then we will try safe cast `Event event` to `ChildEvent? event`.
  ///       // `Event event` here is candidate event
  ///       // return `ChildEvent childEvent` if we are concern about it
  ///       // return null if we are not concern about it
  ///       ...
  ///     },
  ///     duration: ... // time interval used for judgment
  ///   )
  ///   ...
  /// ```
  /// 
  System<State, Event> debounceOn<ChildEvent>({
    ChildEvent? Function(Event event)? test,
    required Duration duration, 
  }) {
    final _test = test ?? safeAs;
    return eventInterceptor<_DebounceOnContext>(
      createContext: () => _DebounceOnContext(),
      interceptor: (context, dispatch, event) {
        final childEvent = _test(event);
        if (childEvent == null) {
          dispatch(event);
        } else {
          final identifier = Object();
          context.identifier = identifier;
          Future<void>.delayed(duration).then((_) {
            if (identical(context.identifier, identifier)) {
              dispatch(event);
            }
          });
        }
      },
      dispose: (context) {
        context.identifier = null;
      },
    );
  }

  /// An interceptor that can intercept event.
  /// 
  /// This is a low level operator which can be used for supporting high level operators
  /// like `system.ignoreEvent` and `system.debounceOn`.
  /// 
  /// ## API Overview
  /// 
  /// The key point for this operator is, we are associating a custom `Context` with it:
  /// 
  /// ```dart
  /// 
  /// class SomeContext { ... }
  /// 
  /// ...
  /// 
  /// system
  ///  .eventInterceptor<SomeContext>(
  ///    createContext: () => SomeContext(), // create context here
  ///    updateContext: (context, state, oldState, event, dispatch) {
  ///      // update context here if needed.
  ///    },
  ///    interceptor: (context, dispatch, event) {
  ///      // intercept event base on the context,
  ///      // call `dispatch(event);` if we pass the event,
  ///      // don't call `dispatch(event);` if we ignore the event.
  ///    },
  ///    dispose: (context) {
  ///      // dispose the context if needed.
  ///    }
  ///  )
  ///  ...
  /// ```
  /// 
  /// ## Usage Example
  /// 
  /// Bellow code shown how to implement high level `system.ignoreEvent` 
  /// based on low level `system.eventInterceptor`:
  /// 
  /// ```dart
  /// class _IgnoreEventContext<State> {
  ///   late State state;
  /// }
  /// 
  /// extension FilterEventOperators<State, Event> on System<State, Event> {
  /// 
  ///   ...
  /// 
  ///   /// Ignore event based on current state and candidate event.
  ///   System<State, Event> ignoreEvent({
  ///     required bool Function(State state, Event event) when
  ///   }) {
  ///     final test = when;
  ///     return eventInterceptor<_IgnoreEventContext<State>>( //  <-- call `this.eventInterceptor`
  ///       createContext: () => _IgnoreEventContext(),
  ///       updateContext: (context, state, oldState, event, dispatch) {
  ///         context.state = state; // cache current state in context
  ///       },
  ///       interceptor: (context, dispatch, event) {
  ///         final shouldIgnoreEvent = test(context.state, event);
  ///         if (!shouldIgnoreEvent) {
  ///           dispatch(event);
  ///         }
  ///       },
  ///     );
  ///   }
  /// }
  /// ```
  /// 
  /// Usage of `system.ignoreEvent`:
  /// 
  /// ```dart
  /// futureSystem
  ///   .ignoreEvent(
  ///     when: (state, event) => event is TriggerLoadData && state.loading
  ///   ) 
  ///   ...
  /// ```
  /// 
  /// Above code shown if the system is already in loading status, 
  /// then upcoming `TriggerLoadData` event will be ignored.
  /// 
  /// We can treat `system.ignoreEvent` as a special case of `system.eventInterceptor`,
  /// As an analogy, if we say `system.ignoreEvent` is a square, then `system.eventInterceptor` is a rectangle.
  /// 
  System<State, Event> eventInterceptor<Context>({
    required Context Function() createContext,
    ContextEffect<Context, State, Event>? updateContext,
    required InterceptorWithContext<Context, Event> interceptor,
    void Function(Context context)? dispose,
  }) {
    return runWithContext<Context>(
      createContext: createContext,
      run: (context, run, nextReduce, nextEffect, nextInterceptor) {
        bool isDisposed = false;
        final Effect<State, Event>? _effect = updateContext == null ? null : (state, oldState, event, dispatch) {
          updateContext(context, state, oldState, event, dispatch);
        };
        final Interceptor<Event> _interceptor = (dispatch) => Dispatch((event) {
          if (isDisposed) return;
          interceptor(context, dispatch, event);          
        });
        final sourceDisposer = run(
          reduce: nextReduce,
          effect: combineEffect(_effect, nextEffect),
          interceptor: combineInterceptor(_interceptor, nextInterceptor),
        );
        return Disposer(() {
          isDisposed = true;
          sourceDisposer();
        });
      },
      dispose: dispose,
    );
  }
}

class _IgnoreEventContext<State> {
  late State state;
}

class _DebounceOnContext {
  Object? identifier;
}