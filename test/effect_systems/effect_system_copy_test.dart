
import 'package:test/test.dart';

import '../test_utils/test_utils.dart';


void main() {

  test('EffectSystem.copy.nothing', () async {

    int invoked = 0;

    final it = await testEffectSystem<String, String>(
      system: createTestEffectSystem(initialState: 'a')
        .copy((run) => ({effect}) {
          invoked += 1;
          return run(
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

  test('EffectSystem.copy.effect', () async {

    int invoked = 0;
    List<String> stateParameters = [];
    List<String?> oldStatesParameters = [];
    List<String?> eventParameters = [];

    final it = await testEffectSystem<String, String>(
      system: createTestEffectSystem(initialState: 'a')
        .copy((run) => ({effect}) {
          return run(
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