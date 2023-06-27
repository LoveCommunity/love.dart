
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

    void effect(String state, String? oldState, String? event, Dispatch<String> dispatch) {
      states.add(state);
      oldStates.add(oldState);
      events.add(event);
      dispatch('e');
      invoked += 1;
    } 
    
    final dispatch = Dispatch<String>((event) {
      dispatchedEvents.add(event);
    });

    final disposer = forwarder.add(effect: effect);

    forwarder.effect('a', null, null, dispatch);

    expect(states, ['a']);
    expect(oldStates, [null]);
    expect(events, [null]);
    expect(dispatchedEvents, ['e']);
    expect(invoked, 1);

    disposer();
  });

  test('EffectForwarder.dispose', () {

    final List<String> states = [];
    final List<String?> oldStates = [];
    final List<String?> events = [];
    final List<String> dispatchedEvents = [];
    int invoked = 0;

    final forwarder = EffectForwarder<String, String>();

    void effect(String state, String? oldState, String? event, Dispatch<String> dispatch) {
      states.add(state);
      oldStates.add(oldState);
      events.add(event);
      dispatch('e');
      invoked += 1;
    } 

    final dispatch = Dispatch<String>((event) {
      dispatchedEvents.add(event);
    });

    final disposer = forwarder.add(effect: effect);

    forwarder.effect('a', null, null, dispatch);

    expect(states, ['a']);
    expect(oldStates, [null]);
    expect(events, [null]);
    expect(dispatchedEvents, ['e']);
    expect(invoked, 1);

    disposer();
   
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

    void effect(String state, String? oldState, String? event, Dispatch<String> dispatch) {
      states.add(state);
      oldStates.add(oldState);
      events.add(event);
      invoked += 1;
    } 

    final disposer = forwarder.add(effect: effect);

    expect(states, <String>[]);
    expect(oldStates, <String?>[]);
    expect(events, <String?>[]);
    expect(invoked, 0);

    disposer();
  });

  test('EffectForwarder.replay.last', () {

    final List<String> states = [];
    final List<String?> oldStates = [];
    final List<String?> events = [];
    final List<String> dispatchedEvents = [];
    int invoked = 0;

    void effect(String state, String? oldState, String? event, Dispatch<String> dispatch) {
      states.add(state);
      oldStates.add(oldState);
      events.add(event);
      dispatch('e');
      invoked += 1;
    } 

    final dispatch = Dispatch<String>((event) {
      dispatchedEvents.add(event);
    });

    final forwarder = EffectForwarder<String, String>();
    forwarder.effect('a', 'b', 'b', dispatch);

    final disposer = forwarder.add(effect: effect);

    expect(states, ['a']);
    expect(oldStates, [null]);
    expect(events, [null]);
    expect(dispatchedEvents, ['e']);
    expect(invoked, 1);

    disposer();
  });

  test('EffectForwarder.forward.order', () {

    final List<int> orders = [];

    final forwarder = EffectForwarder<String, String>();

    void effect1(String state, String? oldState, String? event, Dispatch<String> dispatch) {
      orders.add(1);
    } 

    void effect2(String state, String? oldState, String? event, Dispatch<String> dispatch) {
      orders.add(2);
    } 

    void effect3(String state, String? oldState, String? event, Dispatch<String> dispatch) {
      orders.add(3);
    } 

    final dispatch = Dispatch<String>((_) {});

    final disposer1 = forwarder.add(effect: effect1);
    final disposer2 = forwarder.add(effect: effect2);
    final disposer3 = forwarder.add(effect: effect3);

    forwarder.effect('a', null, null, dispatch);

    expect(orders, [1, 2, 3]);

    disposer2();

    forwarder.effect('a', null, null, dispatch);

    expect(orders, [1, 2, 3, 1, 3]);

    disposer1();
    disposer3();
  });

  test('EffectForwarder.add.afterDisposed', () {
    
    final forwarder = EffectForwarder<String, String>()
      ..dispose();
    
    expect(
      () => forwarder.add(effect: (_, __, ___, ____) { }), 
      throwsStateError
    );
  });

}