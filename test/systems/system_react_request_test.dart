import 'package:test/test.dart';
import 'package:love/love.dart';

import '../test_utils/test_utils.dart';

void main() {

  test('System.reactRequest', () async {

    int invoked = 0;
    int dispatchInvoked = 0;
    List<String> stateParameters = [];
    List<String> requestParameters = [];

    final it = await testSystem<String, String>(
      system: createTestSystem(initialState: 'a')
        .reactRequest<String>(
          request: (state) {
            stateParameters.add(state);
            invoked += 1;
            return state.endsWith('b') ? 'i' : null;
          },
          effect: (request, dispatch) {
            requestParameters.add(request);
            dispatch(request);
            dispatchInvoked += 1;
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
      'i',
      'c',
      'a',
      'b',
      'c',
      'i',
    ]);

    expect(it.states, [
      'a',
      'a|b',
      'a|b|i',
      'a|b|i|c',
      'a|b|i|c|a',
      'a|b|i|c|a|b',
      'a|b|i|c|a|b|c',
      'a|b|i|c|a|b|c|i',
    ]);

    expect(it.oldStates, [
      null,
      'a',
      'a|b',
      'a|b|i',
      'a|b|i|c',
      'a|b|i|c|a',
      'a|b|i|c|a|b',
      'a|b|i|c|a|b|c',
    ]);

    expect(it.isDisposed, true);

    expect(stateParameters, [
      'a',
      'a|b',
      'a|b|i',
      'a|b|i|c',
      'a|b|i|c|a',
      'a|b|i|c|a|b',
      'a|b|i|c|a|b|c',
      'a|b|i|c|a|b|c|i',
    ]);

    expect(requestParameters, [
      'i',
      'i',
    ]);

    expect(invoked, 8);
    expect(dispatchInvoked, 2);
  });

}