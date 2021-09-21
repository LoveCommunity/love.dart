
import 'package:love/src/forwarders/effect_forwarder.dart';
import 'package:test/test.dart';
import 'package:love/love.dart';

void main() {

  test('EffectForwarder.effect', () {

    final List<String> states = [];
    final List<String?> oldStates = [];
    final List<String?> events = [];
    final List<String> dispatchedEvents = [];
    int invoked = 0;

    final forwarder = EffectForwarder<String, String>();

    final Effect<String, String> effect = (state, oldState, event, dispatch) {
      states.add(state);
      oldStates.add(oldState);
      events.add(event);
      dispatch('e');
      invoked += 1;
    }; 
    
    final dispatch = Dispatch<String>((event) {
      dispatchedEvents.add(event);
    });

    final dispose = forwarder.add(effect: effect);

    forwarder.effect('a', null, null, dispatch);

    expect(states, ['a']);
    expect(oldStates, [null]);
    expect(events, [null]);
    expect(dispatchedEvents, ['e']);
    expect(invoked, 1);

    dispose();
  });

  test('EffectForwarder.dispose', () {

    final List<String> states = [];
    final List<String?> oldStates = [];
    final List<String?> events = [];
    final List<String> dispatchedEvents = [];
    int invoked = 0;

    final forwarder = EffectForwarder<String, String>();

    final Effect<String, String> effect = (state, oldState, event, dispatch) {
      states.add(state);
      oldStates.add(oldState);
      events.add(event);
      dispatch('e');
      invoked += 1;
    }; 

    final dispatch = Dispatch<String>((event) {
      dispatchedEvents.add(event);
    });

    final dispose = forwarder.add(effect: effect);

    forwarder.effect('a', null, null, dispatch);

    expect(states, ['a']);
    expect(oldStates, [null]);
    expect(events, [null]);
    expect(dispatchedEvents, ['e']);
    expect(invoked, 1);

    dispose();
   
    forwarder.effect('a|b', 'a', 'b', Dispatch((_) {})); 

    expect(states, ['a']);
    expect(oldStates, [null]);
    expect(events, [null]);
    expect(dispatchedEvents, ['e']);
    expect(invoked, 1);
  });


  test('EffectForwarder.replay.empty', () {

    final List<String> states = [];
    final List<String?> oldStates = [];
    final List<String?> events = [];
    int invoked = 0;

    final forwarder = EffectForwarder<String, String>();

    final Effect<String, String> effect = (state, oldState, event, dispatch) {
      states.add(state);
      oldStates.add(oldState);
      events.add(event);
      invoked += 1;
    }; 

    final dispose = forwarder.add(effect: effect);

    expect(states, <String>[]);
    expect(oldStates, <String?>[]);
    expect(events, <String?>[]);
    expect(invoked, 0);

    dispose();
  });

  test('EffectForwarder.replay.last', () {

    final List<String> states = [];
    final List<String?> oldStates = [];
    final List<String?> events = [];
    final List<String> dispatchedEvents = [];
    int invoked = 0;

    final Effect<String, String> effect = (state, oldState, event, dispatch) {
      states.add(state);
      oldStates.add(oldState);
      events.add(event);
      dispatch('e');
      invoked += 1;
    }; 

    final dispatch = Dispatch<String>((event) {
      dispatchedEvents.add(event);
    });

    final forwarder = EffectForwarder<String, String>();
    forwarder.effect('a', 'b', 'b', dispatch);

    final dispose = forwarder.add(effect: effect);

    expect(states, ['a']);
    expect(oldStates, [null]);
    expect(events, [null]);
    expect(dispatchedEvents, ['e']);
    expect(invoked, 1);

    dispose();
  });

  test('EffectForwarder.forward.order', () {

    final List<int> orders = [];

    final forwarder = EffectForwarder<String, String>();

    final Effect<String, String> effect1 = (state, oldState, event, dispatch) {
      orders.add(1);
    }; 

    final Effect<String, String> effect2 = (state, oldState, event, dispatch) {
      orders.add(2);
    }; 

    final Effect<String, String> effect3 = (state, oldState, event, dispatch) {
      orders.add(3);
    }; 

    final dispatch = Dispatch<String>((_) {});

    final dispose1 = forwarder.add(effect: effect1);
    final dispose2 = forwarder.add(effect: effect2);
    final dispose3 = forwarder.add(effect: effect3);

    forwarder.effect('a', null, null, dispatch);

    expect(orders, [1, 2, 3]);

    dispose2();

    forwarder.effect('a', null, null, dispatch);

    expect(orders, [1, 2, 3, 1, 3]);

    dispose1();
    dispose3();
  });

}