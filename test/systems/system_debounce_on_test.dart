import 'package:test/test.dart';
import 'package:love/love.dart';
import '../test_utils/test_utils.dart';

void main() {

  test('System.debounceOn', () async {

    int testInvoked = 0;
    final List<String> eventParameters = [];

    final it = await testSystem<String, String>(
      system: createTestSystem(initialState: 'a')
        .debounceOn<String>(
          test: (event) {
            eventParameters.add(event);
            testInvoked += 1;
            return event.startsWith('b') ? event : null;
          },
          duration: const Duration(milliseconds: 20)
        ),
      events: (dispatch, dispose) => [
        dispatch(0, 'b1'),
        dispatch(10, 'c'),
        dispatch(20, 'a'),
        dispatch(30, 'b2'),
        dispatch(40, 'b3'),
        dispatch(50, 'b4'),
        dispatch(60, 'c'),
        dispatch(70, 'a'),
        dispatch(80, 'b5'),
        dispose(90),
        dispatch(100, 'c'),
      ],
      awaitMilliseconds: 110,
    );

    expect(it.events, [
      null,
      'c',
      'a',
      'b1',
      'c',
      'a',
      'b4',
    ]);

    expect(it.states, [
      'a',
      'a|c',
      'a|c|a',
      'a|c|a|b1',
      'a|c|a|b1|c',
      'a|c|a|b1|c|a',
      'a|c|a|b1|c|a|b4',
    ]);

    expect(it.oldStates, [
      null,
      'a',
      'a|c',
      'a|c|a',
      'a|c|a|b1',
      'a|c|a|b1|c',
      'a|c|a|b1|c|a',
    ]);

    expect(it.isDisposed, true);

    expect(eventParameters, [
      'b1',
      'c',
      'a',
      'b2',
      'b3',
      'b4',
      'c',
      'a',
      'b5',
    ]);

    expect(testInvoked, 9);
  });
}