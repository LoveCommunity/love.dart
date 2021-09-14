import 'package:test/test.dart';
import 'package:love/love.dart';
import '../test_utils/test_utils.dart';

void main() {

  test('System.eventInterceptor', () async {

    _TestContext? _context;

    final it = await testSystem<String, String>(
      system: createTestSystem(initialState: 'a')
        .eventInterceptor<_TestContext>(
          createContext: () {
            final it = _TestContext();
            _context = it;
            return it;
          },
          updateContext: (context, state, oldState, event, dispatch) {
            context.stateParameters.add(state);
            context.oldStateParameters.add(oldState);
            context.eventParameters.add(event);
            context.updateContextInvoked += 1;
          },
          interceptor: (context, dispatch, event) {
            context.interceptorEventParameters.add(event);
            context.interceptorInvoked += 1;
            if (event == 'd' || event == 'f') return;
            dispatch(event);
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
        dispatch(40, 'f'),
        dispatch(50, 'g'),
        dispose(60),
        dispatch(70, 'h'),
      ],
      awaitMilliseconds: 80,
    );

    expect(it.events, [
      null,
      'b',
      'c',
      'e',
      'g',
    ]);

    expect(it.states, [
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|e',
      'a|b|c|e|g',
    ]);

    expect(it.oldStates, [
      null,
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|e',
    ]);

    expect(it.isDisposed, true);
 
    expect(_context!.stateParameters, [
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|e',
      'a|b|c|e|g',
    ]);

    expect(_context!.oldStateParameters, [
      null,
      'a',
      'a|b',
      'a|b|c',
      'a|b|c|e',
    ]);

    expect(_context!.eventParameters, [
      null,
      'b',
      'c',
      'e',
      'g',
    ]);

    expect(_context!.interceptorEventParameters, [
      'b',
      'c',
      'd',
      'e',
      'f',
      'g',
    ]);

    expect(_context!.isDisposed, true);
    expect(_context!.updateContextInvoked, 5);
    expect(_context!.interceptorInvoked, 6);
  });
}

class _TestContext {
  int updateContextInvoked = 0;
  int interceptorInvoked = 0;
  List<String> stateParameters = [];
  List<String?> oldStateParameters = [];
  List<String?> eventParameters = [];
  List<String?> interceptorEventParameters = [];
  bool isDisposed = false;
}