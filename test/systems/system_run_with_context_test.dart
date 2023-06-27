
import 'package:love/love.dart';
import 'package:test/test.dart';
import '../test_types/test_context.dart';
import '../test_utils/test_utils.dart';

void main() {

  test('System.runWithContext.nothing', () async {

    TestContext? testContext;

    final it = await testSystem<String, String>(
      system: createTestSystem(initialState: 'a')
        .runWithContext<TestContext>(
          createContext: () {
            final it = TestContext();
            testContext = it;
            return it;
          },
          run: (context, run, nextReduce, nextEffect, nextInterceptor) {
            context.invoked += 1;
            return run(
              reduce: nextReduce,
              effect: nextEffect,
              interceptor: nextInterceptor,
            );
          },
          dispose: (context) {
            context.isDisposed = true;
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

    expect(testContext!.invoked, 1);
    expect(testContext!.isDisposed, true);
  });

  test('System.runWithContext.reduce', () async {

    TestContext? testContext;

    final it = await testSystem<String, String>(
      system: createTestSystem(initialState: 'a')
        .runWithContext<TestContext>(
          createContext: () {
            final it = TestContext();
            testContext = it;
            return it;
          },
          run: (context, run, nextReduce, nextEffect, nextInterceptor) {
            return run(
              reduce: (state, event) {
                context.stateParameters.add(state);
                context.eventParameters.add(event);
                context.invoked += 1;
                return '$state+${context.invoked}';
              },
              effect: nextEffect,
              interceptor: nextInterceptor,
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

    expect(testContext!.stateParameters, [
      'a|b',
      'a|b+1|c',
      'a|b+1|c+2|d',
      'a|b+1|c+2|d+3|e', 
    ]);

    expect(testContext!.eventParameters, [
      'b',
      'c',
      'd',
      'e',
    ]);

    expect(testContext!.invoked, 4);
    
  });

  test('System.runWithContext.effect', () async {
   
    TestContext? testContext; 

    final it = await testSystem<String, String>(
      system: createTestSystem(initialState: 'a')
        .runWithContext<TestContext>(
          createContext: () {
            final it = TestContext();
            testContext = it;
            return it;
          },
          run: (context, run, nextReduce, nextEffect, nextInterceptor) {
            return run(
              reduce: nextReduce,
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
              interceptor: nextInterceptor,
            );
          },
          dispose: (context) {
            context.isDisposed = true;
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

    expect(testContext!.invoked, 6);
    expect(testContext!.isDisposed, true);
  });

  test('System.runWithContext.interceptor', () async {
   
    TestContext? testContext; 

    final it = await testSystem<String, String>(
      system: createTestSystem(initialState: 'a')
        .runWithContext<TestContext>(
          createContext: () {
            final it = TestContext();
            testContext = it;
            return it;
          },
          run: (context, run, nextReduce, nextEffect, nextInterceptor) {
            return run(
              reduce: nextReduce,
              effect: nextEffect,
              interceptor: (dispatch) => Dispatch((event) {
                if (event != 'c') {
                  dispatch(event);
                }
                context.eventParameters.add(event);
                context.invoked += 1;
              }),
            );
          },
          dispose: (context) {
            context.isDisposed = true;
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
      'd',
      'e',
    ]);

    expect(it.states, [
      'a',
      'a|b',
      'a|b|d',
      'a|b|d|e',
    ]);

    expect(it.oldStates, [
      null,
      'a',
      'a|b',
      'a|b|d',
    ]);

    expect(it.isDisposed, true);

    expect(testContext!.eventParameters, [
      'b',
      'c',
      'd',
      'e',
      'f',
    ]);

    expect(testContext!.invoked, 5);
    expect(testContext!.isDisposed, true);
  });
}