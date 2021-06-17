import 'package:test/test.dart';
import 'package:love/love.dart';

import '../test_utils/test_utils.dart';

void main() {

  test('EffectSystem.on', () async {

    int invoked = 0;
    List<String> stateParameters = [];
    List<String> eventParameters = [];

    final it = await testEffectSystem<String, String>(
      system: createTestEffectSystem(initialState: 'a')
        .on<String>(
          test: (event) => event == 'b' ? 'i' : null,
          effect: (state, event, dispatch) {
            stateParameters.add(state);
            eventParameters.add(event);
            invoked += 1;
            dispatch(event);
          },
        ),
      events: (dispatch, dispose) => [
        dispatch(0, 'b'),
        dispatch(10, 'a'),
        dispatch(20, 'b'),
        dispose(30),
        dispatch(40, 'f'),
      ],
      awaitMilliseconds: 50,
    );

    expect(it.events, [
      null,
      'b',
      'i',
      'a',
      'b',
      'i',
    ]);

    expect(it.states, [
      'a',
      'a|b',
      'a|b|i',
      'a|b|i|a',
      'a|b|i|a|b',
      'a|b|i|a|b|i',
    ]);

    expect(it.oldStates, [
      null,
      'a',
      'a|b',
      'a|b|i',
      'a|b|i|a',
      'a|b|i|a|b',
    ]);

    expect(it.isDisposed, true);

    expect(stateParameters, [
      'a|b',
      'a|b|i|a|b',
    ]);

    expect(eventParameters, [
      'i',
      'i',
    ]);

    expect(invoked, 2);
  
  });
}