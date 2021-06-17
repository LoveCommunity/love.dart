import 'package:test/test.dart';
import 'package:love/love.dart';

import '../test_utils/test_utils.dart';

void main() {

  test('EffectSystem.onDispose', () async {

    int invoked = 0;

    final it = await testEffectSystem<String, String>(
      system: createTestEffectSystem(initialState: 'a')
        .onDispose(
          run: () {
            invoked += 1;
          },
        ),
      events: (dispatch, dispose) => [
        dispatch(0, 'b'),
        dispatch(10, 'c'),
        dispose(20),
        dispatch(30, 'd'),
        dispose(40),
      ],
      awaitMilliseconds: 50,
    );

    expect(it.events, [
      null,
      'b',
      'c',
    ]);

    expect(it.states, [
      'a',
      'a|b',
      'a|b|c',
    ]);

    expect(it.oldStates, [
      null,
      'a',
      'a|b',
    ]);

    expect(it.isDisposed, true);

    expect(invoked, 1);

  });
}