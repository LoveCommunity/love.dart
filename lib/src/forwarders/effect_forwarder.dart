import '../types/types.dart';
import 'package:meta/meta.dart';

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
///  final dispose = system.run();
///
///  await Future.delayed(Duration(seconds: 3));
///
///  // add effect after system is running.
///  final disposeEffect = forwarder.add(effect: (state, oldState, event, dispatch) {
///    ...
///  },);
///
///  await Future.delayed(Duration(seconds: 3));
///
///  disposeEffect(); // dispose the effect
///  dispose(); // dispose system
///```
/// 
@visibleForTesting
class EffectForwarder<State, Event> {

  List<Effect<State, Event>> _effects = [];
  State? _state;
  Dispatch<Event>? _dispatch;

  /// Forward effect call.
  void effect(State state, State? oldState, Event? event, Dispatch<Event> dispatch) {
    for (var _effect in _effects) {
      _effect(state, oldState, event, dispatch);
    }
    _state = state;
    _dispatch = dispatch;
  }

  /// Register effect to this forwarder. 
  /// 
  /// The returned `Dispose` can be used to cancel registration.
  Dispose add({
    required Effect<State, Event> effect
  }) {
    _effects.add(effect);
    if (_state != null && _dispatch != null) {
      effect(_state!, null, null, _dispatch!);
    }
    return Dispose(() {
      if (_effects.contains(effect)) {
        _effects.remove(effect);
      }
    });
  }
}