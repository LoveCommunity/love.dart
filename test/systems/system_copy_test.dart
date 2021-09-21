import 'package:test/test.dart';
import '../test_utils/test_utils.dart';

void main() {

  test('System.copy.nothing', () async {

    int invoked = 0;

    final it = await testSystem<String, String>(
      system: createTestSystem(initialState: 'a')
        .copy((run) => ({reduce, effect}) {
          invoked += 1;
          return run(
            reduce: reduce,
            effect: effect,
          );
        }),
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
      'a|b',
      'a|b|c',
      'a|b|c|d',
      'a|b|c|d|e',
    ]);

    expect(it.oldStates, [
      null,
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|d',
    ]);

    expect(it.isDisposed, true);

    expect(invoked, 1);
  });

  test('System.copy.reduce', () async {

    int invoked = 0;
    final List<String> stateParameters = [];
    final List<String> eventParameters = [];

    final it = await testSystem<String, String>(
      system: createTestSystem(initialState: 'a')
        .copy((run) => ({reduce, effect}) {
          return run(
            reduce: (state, event) {
              stateParameters.add(state);
              eventParameters.add(event);
              invoked += 1;
              return '$state+$invoked';
            },
            effect: effect,
          );
        }),
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

  test('System.copy.effect', () async {

    int invoked = 0;
    final List<String> stateParameters = [];
    final List<String?> oldStatesParameters = [];
    final List<String?> eventParameters = [];

    final it = await testSystem<String, String>(
      system: createTestSystem(initialState: 'a')
        .copy((run) => ({reduce, effect}) {
          return run(
            reduce: reduce,
            effect: (state, oldState, event, dispatch) {
              if (event == 'c') {
                dispatch('i');
              }
              effect?.call(state, oldState, event, dispatch);
              stateParameters.add(state);
              oldStatesParameters.add(oldState);
              eventParameters.add(event);
              invoked += 1;
            },
          );
        }),
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

    expect(oldStatesParameters, [
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
}