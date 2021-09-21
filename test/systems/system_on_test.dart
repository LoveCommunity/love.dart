
import 'package:test/test.dart';
import 'package:love/love.dart';
import '../test_utils/test_utils.dart';

void main() {

  test('System.on', () async {

    int invoked = 0;
    final List<String> stateParameters = [];
    final List<String> eventParameters = [];

    final it = await testSystem<String, String>(
      system: createTestSystem(initialState: 'a')
        .on<String>(
          test: (event) => event == 'b' ? 'i' : null,
          reduce: (state, event) => '$state|$event',
          effect: (state, event, dispatch) {
            stateParameters.add(state);
            eventParameters.add(event);
            invoked += 1;
            dispatch('c');
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
      'c',
      'a',
      'b',
      'c',
    ]);

    expect(it.states, [
      'a',
      'a|b|i',
      'a|b|i|c',
      'a|b|i|c|a',
      'a|b|i|c|a|b|i',
      'a|b|i|c|a|b|i|c',
    ]);

    expect(it.oldStates, [
      null,
      'a',
      'a|b|i',
      'a|b|i|c',
      'a|b|i|c|a',
      'a|b|i|c|a|b|i',
    ]);

    expect(it.isDisposed, true);

    expect(stateParameters, [
      'a|b|i',
      'a|b|i|c|a|b|i',
    ]);

    expect(eventParameters, [
      'i',
      'i',
    ]);

    expect(invoked, 2);
  
  });
}