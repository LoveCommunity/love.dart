import 'package:test/test.dart';
import 'package:love/love.dart';

import '../test_utils/test_utils.dart';

void main() {
  
  test('EffectSystem.onLatest', () async {

    int testInvoked = 0;
    int effectVersion = 0;
    List<String> eventParameters = [];
    List<String> reqeustParameters = [];
    List<int> disposedVersions = [];

    final it = await testEffectSystem<String, String>(
      system: createTestEffectSystem(initialState: 'a')
        .onLatest<String>(
          test: (event) {
            eventParameters.add(event);
            testInvoked += 1;
            return event == 'b' ? 'i' : null;
          },
          effect: (state, request, dispatch) {
            reqeustParameters.add(request);
            effectVersion += 1;
            delayed(1, () => dispatch(request));
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
      'a|b|i|c|a|b|c|a',
      'a|b|i|c|a|b|c|a|b',
      'a|b|i|c|a|b|c|a|b|c',
      'a|b|i|c|a|b|c|a|b|c|i',
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
      'a|b|i|c|a|b|c|a|b|c',
    ]);

    expect(it.isDisposed, true);

    expect(eventParameters, [
      'b',
      'i',
      'c',
      'a',
      'b',
      'c',
      'a',
      'b',
      'c',
      'i',
    ]);

    expect(reqeustParameters, [
      'i',
      'i',
      'i',
    ]);

    expect(testInvoked, 10);
    expect(effectVersion, 3);
    expect(disposedVersions, [1, 2, 3]);
  });

}