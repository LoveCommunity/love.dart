
import 'package:test/test.dart';
import 'package:love/love.dart';

import '../test_utils/test_utils.dart';

void main() {
  
  test('System.reactLatestRequest', () async {

    int requestInvoked = 0;
    int effectVersion = 0;
    List<String> stateParameters = [];
    List<String> valueParameters = [];
    List<int> disposedVersions = [];

    final it = await testSystem<String, String>(
      system: createTestSystem(initialState: 'a')
        .reactLatestRequest<String>(
          request: (state) {
            stateParameters.add(state);
            requestInvoked += 1;
            return state.endsWith('b') ? 'i' : null;
          },
          effect: (value, dispatch) {
            valueParameters.add(value);
            effectVersion += 1;
            delayed(1, () => dispatch(value)); 
            final version = effectVersion;
            return Dispose(() {
              disposedVersions.add(version);
            });
          },
        ),
      events: (dispatch, dispose) => [
        dispatch(0, 'b'),
        dispatch(10, 'c'),
        dispatch(10, 'a'),
        dispatch(20, 'b'),
        dispatch(20, 'c'),
        dispatch(20, 'a'),
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
      'a',
      'b',
      'c',
    ]);

    expect(it.states, [
      'a',
      'a|b',
      'a|b|i',
      'a|b|i|c',
      'a|b|i|c|a',
      'a|b|i|c|a|b',
      'a|b|i|c|a|b|c',
      'a|b|i|c|a|b|c|a',
      'a|b|i|c|a|b|c|a|b',
      'a|b|i|c|a|b|c|a|b|c',
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
      'a|b|i|c|a|b|c|a',
      'a|b|i|c|a|b|c|a|b',
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
      'a|b|i|c|a|b|c|a',
      'a|b|i|c|a|b|c|a|b',
      'a|b|i|c|a|b|c|a|b|c',
    ]);

    expect(valueParameters, [
      'i',
      'i',
      'i',
    ]);

    expect(requestInvoked, 10);
    expect(effectVersion, 3);
    expect(disposedVersions, [1, 2, 3]);
  });

}