import 'dart:async';
import 'package:love/love.dart';

abstract class TestEvent<Event> {}
class TestEventDispatch<Event> implements TestEvent<Event> {
  final int delay;
  final Event event;
  TestEventDispatch(this.delay, this.event);
}
class TestEventDispose<Event> implements TestEvent<Event> {
  final int delay;
  TestEventDispose(this.delay);
}

class SystemTestResult<State, Event> {

  SystemTestResult({
    required this.states, 
    required this.oldStates, 
    required this.events, 
    required this.isDisposed
  });

  final List<State> states;
  final List<State?> oldStates;
  final List<Event?> events;
  final bool isDisposed;
}

Future<SystemTestResult<State, Event>> testSystem<State, Event>({
  required System<State, Event> system,
  required List<TestEvent<Event>> Function(
    TestEventDispatch<Event> Function(int delay, Event event) dispatch,
    TestEventDispose<Event> Function(int delay) dispose,
  ) events,
  required int awaitMilliseconds,
}) async {

  Disposer? disposer;

  final List<State> states = [];
  final List<State?> oldStates = [];
  final List<Event?> _events = [];
  bool isDisposed = false;

  final _disposer = system.run(
    effect: (state, oldState, event, dispatch) {
      states.add(state);
      oldStates.add(oldState);
      _events.add(event);
      if (event == null) {
        final testEvents = events(
          (delay, event) => TestEventDispatch(delay, event),
          (delay) => TestEventDispose(delay),
        );
        testEvents.forEach((event) {
          if (event is TestEventDispatch<Event>) {
            delayed(event.delay, () => dispatch(event.event));
          } else if (event is TestEventDispose<Event>) {
            delayed(event.delay, () => disposer?.call());
          }
        });
      }
    },
  );
    
  disposer = Disposer(() {
    isDisposed = true;
    _disposer();
  });

  await delayed<Null>(awaitMilliseconds);

  return SystemTestResult(
    states: states,
    oldStates: oldStates,
    events: _events,
    isDisposed: isDisposed,
  );
}

Reduce<String, String> reduce = (state, event) => '$state|$event';

System<String, String> createTestSystem({
  required String initialState,
}) => System<String, String>
  .create(initialState: initialState)
  .add(reduce: reduce);

Future<T> delayed<T>(int milliseconds, [FutureOr<T> Function()? computation]) 
  => Future.delayed(Duration(milliseconds: milliseconds), computation);