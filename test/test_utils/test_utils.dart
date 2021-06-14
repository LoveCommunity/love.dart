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

Reduce<String, String> _reduce = (state, event) => '$state|$event';

Future<SystemTestResult<String, String>> testSystemOperator({
  required String initialState,
  required System<String, String> Function(System<String, String>) operator,
  required List<TestEvent<String>> Function(
    TestEventDispatch<String> Function(int delay, String event) dispatch,
    TestEventDispose<String> Function(int delay) dispose,
  ) events,
  required int awaitMilliseconds,
}) async {
  
  Dispose? dispose;

  List<String> states = [];
  List<String?> oldStates = [];
  List<String?> _events = [];
  bool isDisposed = false;

  final System<String, String> system = () {
    final it = System<String, String>
      .create(initialState: initialState);
    return operator(it);
  }();

  final Effect<String, String> record = (state, oldState, event, dispatch) {
    states.add(state);
    oldStates.add(oldState);
    _events.add(event);
  };

  final Effect<String, String> mock = (state, oldState, event, dispatch) {
    if (event == null) {
      final testEvents = events(
        (delay, event) => TestEventDispatch(delay, event),
        (delay) => TestEventDispose(delay),
      );
      testEvents.forEach((event) {
        if (event is TestEventDispatch<String>) {
          delayed(event.delay, () => dispatch(event.event));
        } else if (event is TestEventDispose<String>) {
          delayed(event.delay, () => dispose?.call());
        }
      });
    }
  };

  final _dispose = system.run(
    reduce: _reduce,
    effect: (state, oldState, event, dispatch) {
      record(state, oldState, event, dispatch);
      mock(state, oldState, event, dispatch);
    },
  );
    
  dispose = Dispose(() {
    isDisposed = true;
    _dispose();
  });

  await delayed<Null>(awaitMilliseconds);

  return SystemTestResult(
    states: states,
    oldStates: oldStates,
    events: _events,
    isDisposed: isDisposed,
  );
}

Future<T> delayed<T>(int milliseconds, [FutureOr<T> Function()? computation]) 
  => Future.delayed(Duration(milliseconds: milliseconds), computation);