

import 'package:test/test.dart';
import 'package:love/love.dart';

import '../test_utils/test_utils.dart';

void main() {

  test('EffectSystem.create', () async {
    
    final it = await testEffectSystem<String, String>(
      system: EffectSystem<String, String>
        .create(
          initialState: 'a',
          reduce: reduce,
        ),
      events: (dispatch, dispose) => [],
      awaitMilliseconds: 0,
    );

    expect(it.isDisposed, false);
    expect(it.events, [null]);
    expect(it.states, ['a']);
    expect(it.oldStates, [null]);
  });

}