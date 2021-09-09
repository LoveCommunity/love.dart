
import 'package:test/test.dart';
import 'package:love/love.dart';

import '../test_utils/test_utils.dart';

void main() {

  test('System.log', () async {
    
    final List<String> messages = [];

    final it = await testSystem<String, String>(
      system: createTestSystem(initialState: 'a')
        .log(
          label: 'TestSystem',
          print: (message) {
            messages.add(message);
          },
        ),
      events: (dispatch, dispose) => [
        dispatch(0, 'b'),
        dispatch(10, 'c'),
        dispatch(10, 'a'),
        dispatch(20, 'b'),
        dispatch(20, 'c'),
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

    expect(it.isDisposed, true);

    expect(messages, [
      'TestSystem Run',
      'TestSystem Update {\n  event: null\n  oldState: null\n  state: a\n}',
      'TestSystem Update {\n  event: b\n  oldState: a\n  state: a|b\n}',
      'TestSystem Update {\n  event: c\n  oldState: a|b\n  state: a|b|c\n}',
      'TestSystem Update {\n  event: a\n  oldState: a|b|c\n  state: a|b|c|a\n}',
      'TestSystem Update {\n  event: b\n  oldState: a|b|c|a\n  state: a|b|c|a|b\n}',
      'TestSystem Update {\n  event: c\n  oldState: a|b|c|a|b\n  state: a|b|c|a|b|c\n}',
      'TestSystem Dispose',
    ]);
  });
}