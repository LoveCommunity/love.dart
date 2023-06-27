import 'package:test/test.dart';

import '../test_types/test_context.dart';
import '../test_utils/test_utils.dart';

void main() {
  
  test('System.withContext.reduce', () async {
    
    TestContext? testContext;

    int invoked = 0;
    final List<String> stateParameters = [];
    final List<String> eventParameters = [];
    
    final it = await testSystem<String, String>(
      system: createTestSystem(initialState: 'a')
        .withContext<TestContext>(
          createContext: () {
            final it = TestContext();
            testContext = it;
            return it;
          },
          reduce: (state, event) {
            stateParameters.add(state);
            eventParameters.add(event);
            invoked += 1;
            return '$state+$invoked';
          },
          dispose: (context) => context.isDisposed = true,
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
      'a|b+1',
      'a|b+1|c+2',
      'a|b+1|c+2|d+3',
      'a|b+1|c+2|d+3|e+4',
    ]);

    expect(it.oldStates, [
      null,
      'a',
      'a|b+1',
      'a|b+1|c+2',
      'a|b+1|c+2|d+3',
    ]);

    expect(it.isDisposed, true);

    expect(stateParameters, [
      'a|b',
      'a|b+1|c',
      'a|b+1|c+2|d',
      'a|b+1|c+2|d+3|e', 
    ]);

    expect(eventParameters, [
      'b',
      'c',
      'd',
      'e',
    ]);

    expect(testContext!.isDisposed, true);
    expect(invoked, 4);
  });

  test('System.withContext.effect', () async {

    TestContext? testContext; 

    final it = await testSystem<String, String>(
      system: createTestSystem(initialState: 'a')
        .withContext<TestContext>(
          createContext: () {
            final it = TestContext();
            testContext = it;
            return it;
          },
          effect: (context, state, oldState, event, dispatch) {
            if (event == 'c') {
              dispatch('i');
            }
            context.stateParameters.add(state);
            context.oldStateParameters.add(oldState);
            context.eventParameters.add(event);
            context.invoked += 1;
          },
          dispose: (context) => context.isDisposed = true,
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

    expect(testContext!.stateParameters, [
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|i',
      'a|b|c|i|d',
      'a|b|c|i|d|e',
    ]);

    expect(testContext!.oldStateParameters, [
      null,
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|i',
      'a|b|c|i|d',
    ]);

    expect(testContext!.eventParameters, [
      null,
      'b',
      'c',
      'i',
      'd',
      'e',
    ]);

    expect(testContext!.isDisposed, true);
    expect(testContext!.invoked, 6);
  });
}