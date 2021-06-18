
import 'package:test/test.dart';
import 'package:love/love.dart';

import '../test_utils/test_utils.dart';

void main() {

  test('EffectSystem.run', () async {

    Dispose? dispose;

    List<String> states = [];
    List<String?> oldStates = [];
    List<String?> events = [];
    bool isDisposed = false;

    final system = createTestEffectSystem(initialState: 'a');
    
    final _dispose = system.run(
      effect: (state, oldState, event, dispatch) {
        states.add(state);
        oldStates.add(oldState);
        events.add(event);
        if (event == null) {
          delayed(0, () => dispatch('b'));
          delayed(10, () => dispatch('c'));
          delayed(20, () => dispatch('d'));
          delayed(30, () => dispatch('e'));
          delayed(40, () => dispose?.call());
          delayed(50, () => dispatch('f'));
        }
      },
    );

    dispose = Dispose(() {
      isDisposed = true;
      _dispose();
    });

    await delayed<Null>(60);
  
    expect(events, [
      null,
      'b',
      'c',
      'd',
      'e',
    ]);

    expect(states, [
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|d',
      'a|b|c|d|e',
    ]);

    expect(oldStates, [
      null,
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|d',
    ]);

    expect(isDisposed, true);
    
  });
}