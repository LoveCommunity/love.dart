import 'package:test/test.dart';
import 'package:love/love.dart';

import '../test_utils/test_utils.dart';

void main() {

  test('System.reactLatest', () async {

    int valueInvoked = 0;
    int effectInvoked = 0;
    int effectVersion = 0;
    final List<String> stateParameters = [];
    final List<String> valueParameters = [];
    final List<int> disposedVersions = [];

    final it = await testSystem<String, String>(
      system: createTestSystem(initialState: 'a')
        .reactLatest<String>(
          skipInitialValue: false,
          value: (state) {
            stateParameters.add(state);
            valueInvoked += 1;
            return state.substring(state.length - 1);
          },
          effect: (value, dispatch) {
            valueParameters.add(value);
            effectInvoked += 1;
            if (value == 'b') {
              effectVersion += 1;
              delayed(1, () => dispatch('i'));
              final version = effectVersion;
              return Dispose(() {
                disposedVersions.add(version);
              });
            }
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
    ]);

    expect(it.states, [
      'a',
      'a|b',
      'a|b|i',
      'a|b|i|c',
      'a|b|i|c|a',
      'a|b|i|c|a|b',
      'a|b|i|c|a|b|c',
    ]);

    expect(it.oldStates, [
      null,
      'a',
      'a|b',
      'a|b|i',
      'a|b|i|c',
      'a|b|i|c|a',
      'a|b|i|c|a|b',
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
    ]);

    expect(valueParameters, [
      'a',
      'b',
      'i',
      'c',
      'a',
      'b',
      'c',
    ]);
    
    expect(valueInvoked, 7);
    expect(effectInvoked, 7);
    expect(effectVersion, 2);

    expect(disposedVersions, [1, 2]);
  });

  test('System.reactLatest.skipInitialValue', () async {

    int valueInvoked = 0;
    int effectInvoked = 0;
    int effectVersion = 0;
    final List<String> stateParameters = [];
    final List<String> valueParameters = [];
    final List<int> disposedVersions = [];

    final it = await testSystem<String, String>(
      system: createTestSystem(initialState: 'a')
        .reactLatest<String>(
          skipInitialValue: true,
          value: (state) {
            stateParameters.add(state);
            valueInvoked += 1;
            return state.substring(state.length - 1);
          },
          effect: (value, dispatch) {
            valueParameters.add(value);
            effectInvoked += 1;
            if (value == 'b') {
              effectVersion += 1;
              delayed(1, () => dispatch('i'));
              final version = effectVersion;
              return Dispose(() {
                disposedVersions.add(version);
              });
            }
          },
        ),
      events: (dispatch, dispose) => [
        dispatch(0, 'a'),
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
      'a',
      'b',
      'i',
      'c',
      'a',
      'b',
      'c',
    ]);

    expect(it.states, [
      'a',
      'a|a',
      'a|a|b',
      'a|a|b|i',
      'a|a|b|i|c',
      'a|a|b|i|c|a',
      'a|a|b|i|c|a|b',
      'a|a|b|i|c|a|b|c',
    ]);

    expect(it.oldStates, [
      null,
      'a',
      'a|a',
      'a|a|b',
      'a|a|b|i',
      'a|a|b|i|c',
      'a|a|b|i|c|a',
      'a|a|b|i|c|a|b',
    ]);

    expect(it.isDisposed, true);

    expect(stateParameters, [
      'a',
      'a|a',
      'a|a|b',
      'a|a|b|i',
      'a|a|b|i|c',
      'a|a|b|i|c|a',
      'a|a|b|i|c|a|b',
      'a|a|b|i|c|a|b|c',
    ]);

    expect(valueParameters, [
      'b',
      'i',
      'c',
      'a',
      'b',
      'c',
    ]);
    
    expect(valueInvoked, 8);
    expect(effectInvoked, 6);
    expect(effectVersion, 2);

    expect(disposedVersions, [1, 2]);
  });

}