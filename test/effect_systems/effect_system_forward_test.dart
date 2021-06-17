
import 'package:test/test.dart';

import '../test_utils/test_utils.dart';

void main() {

  test('EffectSystem.forward.nothing', () async {

    final it = await testEffectSystem<String, String>(
      system: createTestEffectSystem(initialState: 'a')
        .forward(copy: (system) => system),
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

  });

  test('EffectSystem.forward.copy', () async {

    int invoked = 0;

    final it = await testEffectSystem<String, String>(
      system: createTestEffectSystem(initialState: 'a')
        .forward(copy: (system) => 
          system.copy((run) => ({reduce, effect}) {
            invoked += 1;
            return run(
              reduce: reduce, 
              effect: effect,
            );
        })),
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
}