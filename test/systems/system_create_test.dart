
import 'package:love/love.dart';
import 'package:test/test.dart';

void main() {

  test('System.create', () async {

    List<String> states = [];
    List<String?> oldStates = [];
    List<String?> events = [];

    final system = System<String, String>
      .create(initialState: 'a');

    final dispose = system.run(
      reduce: (state, event) => '$state|$event',
      effect: (state, oldState, event, dispatch) {
        states.add(state);
        oldStates.add(oldState);
        events.add(event);
      }
    );

    expect(events, [null]);
    expect(states, ['a']);
    expect(oldStates, [null]);

    dispose();
    
  });
}