
import 'package:test/test.dart';
import 'package:love/love.dart';

import '../test_utils/test_utils.dart';

void main() {

  test('EffectSystem.onEvent', () async {
    
    int invoked = 0;
    int dispatchInvoked = 0;
    List<String> stateParameters = [];
    List<String?> eventParameters = [];

    final it = await testEffectSystem<String, String>(
      system: createTestEffectSystem(initialState: 'a')
        .onEvent(
          effect: (state, event, dispatch) {
            if (event == 'b') {
              dispatch('c');
              dispatchInvoked += 1;
            }
            stateParameters.add(state);
            eventParameters.add(event);
            invoked += 1;
          },
        ),
      events: (dispatch, dispose) => [
        dispatch(0, 'b'),
        dispatch(10, 'a'),
        dispatch(20, 'b'),
        dispose(30),
        dispatch(40, 'a'),
        dispatch(50, 'b'),
      ],
      awaitMilliseconds: 60,
    );

    expect(it.events, [
      null,
      'b',
      'c',
      'a',
      'b',
      'c',
    ]);

    expect(it.states, [
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|a',
      'a|b|c|a|b',
      'a|b|c|a|b|c',
    ]);

    expect(it.oldStates, [
      null,
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|a',
      'a|b|c|a|b',
    ]);

    expect(stateParameters, [
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|a',
      'a|b|c|a|b',
      'a|b|c|a|b|c',
    ]);

    expect(eventParameters, [
      null,
      'b',
      'c',
      'a',
      'b',
      'c',
    ]);

    expect(invoked, 6);
    expect(dispatchInvoked, 2);
  });
}