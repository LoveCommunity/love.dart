
import 'package:test/test.dart';
import 'package:love/love.dart';
import '../test_utils/test_utils.dart';


void main() {

  test('System.run', () async {

    Disposer? disposer;

    final List<String> states = [];
    final List<String?> oldStates = [];
    final List<String?> events = [];
    bool isDisposed = false;

    final system = createTestSystem(initialState: 'a');
    
    final localDisposer = system.run(
      effect: (state, oldState, event, dispatch) {
        states.add(state);
        oldStates.add(oldState);
        events.add(event);
        if (event == null) {
          delayed(0, () => dispatch('b'));
          delayed(10, () => dispatch('c'));
          delayed(20, () => dispatch('d'));
          delayed(30, () => dispatch('e'));
          delayed(40, () => disposer?.call());
          delayed(50, () => dispatch('f'));
        }
      },
    );

    disposer = Disposer(() {
      isDisposed = true;
      localDisposer();
    });

    await delayed<void>(60);
  
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