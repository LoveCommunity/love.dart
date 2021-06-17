import 'package:test/test.dart';
import 'package:love/love.dart';

import '../test_utils/test_utils.dart';

void main() {
 
  test('EffectSystem.shareForever', () async {

    int disposeInvoked = 0;
    int disposeInvoked1 = 0;
    int disposeInvoked2 = 0;
    List<String> stateParameters = [];
    List<String?> oldStatesParameters = [];
    List<String?> eventParameters = [];
    List<String?> eventParameters1 = [];
    List<String?> eventParameters2 = [];

    Dispose? dispose1;
    Dispose? dispose2;
    
    final system = createTestEffectSystem(initialState: 'a')
      .withContext<Null>(
        createContext: () => null,
        effect: (_, state, oldState, event, dispatch) {
          stateParameters.add(state);
          oldStatesParameters.add(oldState);
          eventParameters.add(event);
          if (event == null) {
            delayed(0, () => dispatch('b'));
            delayed(10, () => dispatch('c'));
            delayed(40, () => dispatch('a'));
            delayed(50, () => dispatch('b'));
            delayed(60, () => dispatch('c'));
            delayed(90, () => dispatch('a'));
            delayed(100, () => dispatch('b'));
            delayed(110, () => dispatch('c'));
          }
        },
        dispose: (_) {
          disposeInvoked += 1;
        },
      )
      .shareForever();

    delayed(20, () => dispose2?.call());
    delayed(70, () => dispose1?.call());
    
    dispose1 = () {
      final _dispose1 = system
        .run(effect: (state, oldState, event, dispatch) {
          eventParameters1.add(event);
        });
      return Dispose(() {
        disposeInvoked1 += 1;
        _dispose1();
      });
    }(); 

    
    dispose2 = () {
      final _dispose2 = system
        .run(effect: (state, oldState, event, dispatch) {
          eventParameters2.add(event);
        });
      return Dispose(() {
        disposeInvoked2 += 1;
        _dispose2();
      });
    }();

    await delayed<Null>(30);

    expect(disposeInvoked, 0);
    expect(disposeInvoked1, 0);
    expect(disposeInvoked2, 1);

    await delayed<Null>(120 - 30);

    expect(eventParameters, [
      null,
      'b',
      'c',
      'a',
      'b',
      'c',
      'a',
      'b',
      'c',
    ]);

    expect(stateParameters, [
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|a',
      'a|b|c|a|b',
      'a|b|c|a|b|c',
      'a|b|c|a|b|c|a',
      'a|b|c|a|b|c|a|b',
      'a|b|c|a|b|c|a|b|c',
    ]);

    expect(oldStatesParameters, [
      null,
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|a',
      'a|b|c|a|b',
      'a|b|c|a|b|c',
      'a|b|c|a|b|c|a',
      'a|b|c|a|b|c|a|b',
    ]);

    expect(eventParameters1, [
      null,
      'b',
      'c',
      'a',
      'b',
      'c',
    ]);

    expect(eventParameters2, [
      null,
      'b',
      'c',
    ]);

    expect(disposeInvoked, 0);
    expect(disposeInvoked1, 1);
    expect(disposeInvoked2, 1);
  });
}