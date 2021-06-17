
import 'package:test/test.dart';
import 'package:love/love.dart';

import '../test_types/test_context.dart';
import '../test_utils/test_utils.dart';


void main() {
  
  test('EffectSystem.runWithContext.nothing', () async {

    TestContext? _context;

    final it = await testEffectSystem<String, String>(
      system: createTestEffectSystem(initialState: 'a')
        .runWithContext<TestContext>(
          createContext: () {
            final it = TestContext();
            _context = it;
            return it;
          },
          run: (context, run, nextEffect) {
            context.invoked += 1;
            final dispose = run(
              effect: nextEffect
            );
            return Dispose(() {
              context.isDisposed = true;
              dispose();
            });
          },
        ),
      events: (dispatch, dispose) => [
        dispatch(0, 'b'),
        dispatch(10, 'c'),
        dispatch(20, 'd'),
        dispatch(30, 'e'),
        dispose(40),
        dispatch(50, 'f'),
      ],
      awaitMilliseconds: 60,
    );

    expect(it.events, [
      null,
      'b',
      'c',
      'd',
      'e',
    ]);

    expect(it.states, [
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|d',
      'a|b|c|d|e',
    ]);

    expect(it.oldStates, [
      null,
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|d',
    ]);

    expect(it.isDisposed, true);

    expect(_context!.invoked, 1);
    expect(_context!.isDisposed, true);
  });

  test('EffectSystem.runWithContext.effect', () async {
   
    TestContext? _context; 

    final it = await testEffectSystem<String, String>(
      system: createTestEffectSystem(initialState: 'a')
        .runWithContext<TestContext>(
          createContext: () {
            final it = TestContext();
            _context = it;
            return it;
          },
          run: (context, run, nextEffect) {
            return run(
              effect: (state, oldState, event, dispatch) {
                if (event == 'c') {
                  dispatch('i');
                }
                nextEffect?.call(state, oldState, event, dispatch);
                context.stateParameters.add(state);
                context.oldStateParameters.add(oldState);
                context.eventParameters.add(event);
                context.invoked += 1;
              },
            );
          },
        ),
      events: (dispatch, dispose) => [
        dispatch(0, 'b'),
        dispatch(10, 'c'),
        dispatch(20, 'd'),
        dispatch(30, 'e'),
        dispose(40),
        dispatch(50, 'f'),
      ],
      awaitMilliseconds: 60,
    );

    expect(it.events, [
      null,
      'b',
      'c',
      'i',
      'd',
      'e',
    ]);

    expect(it.states, [
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|i',
      'a|b|c|i|d',
      'a|b|c|i|d|e',
    ]);

    expect(it.oldStates, [
      null,
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|i',
      'a|b|c|i|d',
    ]);

    expect(it.isDisposed, true);

    expect(_context!.stateParameters, [
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|i',
      'a|b|c|i|d',
      'a|b|c|i|d|e',
    ]);

    expect(_context!.oldStateParameters, [
      null,
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|i',
      'a|b|c|i|d',
    ]);

    expect(_context!.eventParameters, [
      null,
      'b',
      'c',
      'i',
      'd',
      'e',
    ]);

    expect(_context!.invoked, 6);
  });
}
