import 'package:test/test.dart';

import '../test_utils/test_utils.dart';


void main() {
  
  test('System.add.reduce', () async {

    int invoked = 0;
    final List<String> stateParameters = [];
    final List<String> eventParameters = [];

    final it = await testSystem<String, String>(
      system: createTestSystem(initialState: 'a')
        .add(
          reduce: (state, event) {
            stateParameters.add(state);
            eventParameters.add(event);
            invoked += 1;
            return '$state+$invoked';
          },
        ),
      events: (dispatch, dispose) => [
        dispatch(0, 'b'),
        dispatch(10, 'c'),
        dispatch(20, 'd'),
        dispatch(30, 'e'),
        dispose(40),
        dispatch(50, 'f'),
      ],
      awaitMilliseconds: 60,
    );

    expect(it.events, [
      null,
      'b',
      'c',
      'd',
      'e',
    ]);

    expect(it.states, [
      'a',
      'a|b+1',
      'a|b+1|c+2',
      'a|b+1|c+2|d+3',
      'a|b+1|c+2|d+3|e+4',
    ]);

    expect(it.oldStates, [
      null,
      'a',
      'a|b+1',
      'a|b+1|c+2',
      'a|b+1|c+2|d+3',
    ]);

    expect(it.isDisposed, true);

    expect(stateParameters, [
      'a|b',
      'a|b+1|c',
      'a|b+1|c+2|d',
      'a|b+1|c+2|d+3|e', 
    ]);

    expect(eventParameters, [
      'b',
      'c',
      'd',
      'e',
    ]);

    expect(invoked, 4);
  });

  test('System.add.reduce.order', () async {

    int invoked1 = 0;
    final List<String> stateParameters1 = [];
    final List<String> eventParameters1 = [];

    int invoked2 = 0;
    final List<String> stateParameters2 = [];
    final List<String> eventParameters2 = [];

    final List<int> orders = [];

    final it = await testSystem<String, String>(
      system: createTestSystem(initialState: 'a')
        .add(
          reduce: (state, event) {
            stateParameters1.add(state);
            eventParameters1.add(event);
            invoked1 += 1;
            orders.add(1);
            return '$state+$invoked1';
          },
        ).add(
          reduce: (state, event) {
            stateParameters2.add(state);
            eventParameters2.add(event);
            invoked2 += 1;
            orders.add(2);
            return '$state++$invoked2';
          },
        ),
      events: (dispatch, dispose) => [
        dispatch(0, 'b'),
        dispatch(10, 'c'),
        dispatch(20, 'd'),
        dispatch(30, 'e'),
        dispose(40),
        dispatch(50, 'f'),
      ],
      awaitMilliseconds: 60,
    );

    expect(it.events, [
      null,
      'b',
      'c',
      'd',
      'e',
    ]);

    expect(it.states, [
      'a',
      'a|b+1++1',
      'a|b+1++1|c+2++2',
      'a|b+1++1|c+2++2|d+3++3',
      'a|b+1++1|c+2++2|d+3++3|e+4++4',
    ]);

    expect(it.oldStates, [
      null,
      'a',
      'a|b+1++1',
      'a|b+1++1|c+2++2',
      'a|b+1++1|c+2++2|d+3++3',
    ]);

    expect(it.isDisposed, true);

    expect(stateParameters1, [
      'a|b',
      'a|b+1++1|c',
      'a|b+1++1|c+2++2|d',
      'a|b+1++1|c+2++2|d+3++3|e', 
    ]);

    expect(eventParameters1, [
      'b',
      'c',
      'd',
      'e',
    ]);

    expect(invoked1, 4);

    expect(stateParameters2, [
      'a|b+1',
      'a|b+1++1|c+2',
      'a|b+1++1|c+2++2|d+3',
      'a|b+1++1|c+2++2|d+3++3|e+4', 
    ]);

    expect(eventParameters2, [
      'b',
      'c',
      'd',
      'e',
    ]);

    expect(invoked2, 4);

    expect(orders, [
      1, 2,
      1, 2,
      1, 2,
      1, 2,
    ]);
  });

  test('System.add.effect', () async {

    int invoked = 0;
    final List<String> stateParameters = [];
    final List<String?> oldStateParameters = [];
    final List<String?> eventParameters = [];

    final it = await testSystem<String, String>(
      system: createTestSystem(initialState: 'a')
        .add(
          effect: (state, oldState, event, dispatch) {
            if (event == 'c') {
              dispatch('i');
            }
            stateParameters.add(state);
            oldStateParameters.add(oldState);
            eventParameters.add(event);
            invoked += 1;
          },
        ),
      events: (dispatch, dispose) => [
        dispatch(0, 'b'),
        dispatch(10, 'c'),
        dispatch(20, 'd'),
        dispatch(30, 'e'),
        dispose(40),
        dispatch(50, 'f'),
      ],
      awaitMilliseconds: 60,
    );

    expect(it.events, [
      null,
      'b',
      'c',
      'i',
      'd',
      'e',
    ]);

    expect(it.states, [
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|i',
      'a|b|c|i|d',
      'a|b|c|i|d|e',
    ]);

    expect(it.oldStates, [
      null,
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|i',
      'a|b|c|i|d',
    ]);

    expect(it.isDisposed, true);

    expect(stateParameters, [
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|i',
      'a|b|c|i|d',
      'a|b|c|i|d|e',
    ]);

    expect(oldStateParameters, [
      null,
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|i',
      'a|b|c|i|d',
    ]);

    expect(eventParameters, [
      null,
      'b',
      'c',
      'i',
      'd',
      'e',
    ]);

    expect(invoked, 6);

  });

  test('System.add.effect.order', () async {

    int invoked1 = 0;
    final List<String> stateParameters1 = [];
    final List<String?> oldStateParameters1 = [];
    final List<String?> eventParameters1 = [];

    int invoked2 = 0;
    final List<String> stateParameters2 = [];
    final List<String?> oldStateParameters2 = [];
    final List<String?> eventParameters2 = [];

    final List<int> orders = [];

    final it = await testSystem<String, String>(
      system: createTestSystem(initialState: 'a')
        .add(
          effect: (state, oldState, event, dispatch) {
            if (event == 'c') {
              dispatch('i');
            }
            stateParameters1.add(state);
            oldStateParameters1.add(oldState);
            eventParameters1.add(event);
            invoked1 += 1;
            orders.add(1);
          },
        ).add(
          effect: (state, oldState, event, dispatch) {
            if (event == 'c') {
              dispatch('j');
            }
            stateParameters2.add(state);
            oldStateParameters2.add(oldState);
            eventParameters2.add(event);
            invoked2 += 1;
            orders.add(2);
          },
        ),
      events: (dispatch, dispose) => [
        dispatch(0, 'b'),
        dispatch(10, 'c'),
        dispatch(20, 'd'),
        dispatch(30, 'e'),
        dispose(40),
        dispatch(50, 'f'),
      ],
      awaitMilliseconds: 60,
    );

    expect(it.events, [
      null,
      'b',
      'c',
      'i',
      'j',
      'd',
      'e',
    ]);

    expect(it.states, [
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|i',
      'a|b|c|i|j',
      'a|b|c|i|j|d',
      'a|b|c|i|j|d|e',
    ]);

    expect(it.oldStates, [
      null,
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|i',
      'a|b|c|i|j',
      'a|b|c|i|j|d',
    ]);

    expect(it.isDisposed, true);

    expect(stateParameters1, [
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|i',
      'a|b|c|i|j',
      'a|b|c|i|j|d',
      'a|b|c|i|j|d|e',
    ]);

    expect(oldStateParameters1, [
      null,
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|i',
      'a|b|c|i|j',
      'a|b|c|i|j|d',
    ]);

    expect(eventParameters1, [
      null,
      'b',
      'c',
      'i',
      'j',
      'd',
      'e',
    ]);

    expect(invoked1, 7);

    expect(stateParameters2, [
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|i',
      'a|b|c|i|j',
      'a|b|c|i|j|d',
      'a|b|c|i|j|d|e',
    ]);

    expect(oldStateParameters2, [
      null,
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|i',
      'a|b|c|i|j',
      'a|b|c|i|j|d',
    ]);

    expect(eventParameters2, [
      null,
      'b',
      'c',
      'i',
      'j',
      'd',
      'e',
    ]);

    expect(invoked2, 7);

    expect(orders, [
      1, 2,
      1, 2,
      1, 2,
      1, 2,
      1, 2,
      1, 2,
      1, 2,
    ]);

  });
}