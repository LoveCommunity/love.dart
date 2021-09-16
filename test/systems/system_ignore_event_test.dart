import 'package:test/test.dart';
import 'package:love/love.dart';
import '../test_utils/test_utils.dart';

void main() {

  test('System.ignoreEvent', () async {

    int whenInvoked = 0;
    List<String> stateParameters = [];
    List<String> eventParameters = [];
    
    final it = await testSystem<String, String>(
      system: createTestSystem(initialState: 'a')
        .ignoreEvent(
          when: (state, event) {
            stateParameters.add(state);
            eventParameters.add(event);
            whenInvoked += 1;
            return event == 'b' && state.contains('b');
          },
        ),
      events: (dispatch, dispose) => [
        dispatch(0, 'b'),
        dispatch(10, 'c'),
        dispatch(20, 'a'),
        dispatch(30, 'b'),
        dispatch(40, 'c'),
        dispatch(50, 'a'),
        dispatch(60, 'b'),
        dispatch(70, 'c'),
        dispose(80),
        dispatch(90, 'a'),
      ],
      awaitMilliseconds: 100,
    );

    expect(it.events, [
      null,
      'b',
      'c',
      'a',
      'c',
      'a',
      'c',
    ]);

    expect(it.states, [
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|a',
      'a|b|c|a|c',
      'a|b|c|a|c|a',
      'a|b|c|a|c|a|c',
    ]);

    expect(it.oldStates, [
      null,
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|a',
      'a|b|c|a|c',
      'a|b|c|a|c|a',
    ]);

    expect(it.isDisposed, true);

    expect(stateParameters, [
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|a',
      'a|b|c|a',
      'a|b|c|a|c',
      'a|b|c|a|c|a',
      'a|b|c|a|c|a',
    ]);

    expect(eventParameters, [
      'b',
      'c',
      'a',
      'b',
      'c',
      'a',
      'b',
      'c'
    ]);

    expect(whenInvoked, 8);

  });
}
