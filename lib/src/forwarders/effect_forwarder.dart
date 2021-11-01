import '../types/types.dart' show Dispatch, Disposer, Effect;

/// `EffectForwarder` can forward effect from one side to another.
/// 
/// It's useful when we need to add effect after system is running:
///
///```dart
///  final forwarder = EffectForwarder<State, Event>();
///  
///  final system = System<State, Event>
///    ...
///    .add(effect: forwarder.effect); // forward effect
///
///  final disposer = system.run();
///
///  await Future<void>.delayed(const Duration(seconds: 6));
///
///  // add effect after system is running.
///  final effectDisposer = forwarder.add(effect: (state, oldState, event, dispatch) {
///    ...
///  },);
///
///  await Future<void>.delayed(const Duration(seconds: 6));
///
///  effectDisposer(); // dispose the effect
///  disposer(); // dispose system
///```
/// 
class EffectForwarder<State, Event> {

  final List<Effect<State, Event>> _effects = [];
  State? _state;
  Dispatch<Event>? _dispatch;
  bool _isDisposed = false;

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _effects.clear();
    _state = null;
    _dispatch = null;
  }

  /// Forward effect call.
  void effect(State state, State? oldState, Event? event, Dispatch<Event> dispatch) {
    if (_isDisposed) return;
    for (var _effect in _effects) {
      _effect(state, oldState, event, dispatch);
    }
    _state = state;
    _dispatch = dispatch;
  }

  /// Register effect to this forwarder. 
  /// 
  /// The returned `Disposer` can be used to cancel registration.
  Disposer add({
    required Effect<State, Event> effect
  }) {
    if (_isDisposed) throw StateError('Cannot add effect after disposed');
    _effects.add(effect);
    if (_state != null && _dispatch != null) {
      effect(_state!, null, null, _dispatch!);
    }
    return Disposer(() {
      if (_effects.contains(effect)) {
        _effects.remove(effect);
      }
    });
  }
}