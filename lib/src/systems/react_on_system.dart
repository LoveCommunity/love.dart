import 'system.dart';
import '../types/types.dart';
import '../types/latest_context.dart';

extension ReactOperators<State, Event> on System<State, Event> {

  /// Add `effect` triggered by react hole state change.
  /// 
  /// [areEqual] describe how old state and new state are treat as equal (not change).
  /// 
  /// [skipInitialState] is true if initial state is skipped and won't trigger effect,
  /// is false if initial state will trigger effect, default is true.
  /// 
  /// [effect] describe side effect.
  System<State, Event> reactState({
    AreEqual<State>? areEqual,
    bool skipInitialState = true,
    required void Function(State state, Dispatch<Event> dispatch) effect,
  }) => react<State>(
    value: (state) => state,
    areEqual: areEqual,
    skipInitialValue: skipInitialState,
    effect: effect
  );

  /// Add `effect` triggered by react partial state value change.
  /// 
  /// [value] describe which part of value is observed.
  /// 
  /// [areEqual] describe how old value and new value are treat as equal (not change).
  /// 
  /// [skipInitialValue] is true if initial value is skipped and won't trigger effect, 
  /// is false if initial value will trigger effect, default is true.  
  ///
  /// [effect] describe side effect.
  System<State, Event> react<Value>({
    required Value Function(State state) value,
    AreEqual<Value>? areEqual,
    bool skipInitialValue = true,
    required void Function(Value value, Dispatch<Event> dispatch) effect,
  }) {
    final _areEqual = areEqual ?? defaultAreEqual;
    return withContext<_ReactContext<Value>>(
      createContext: () => _ReactContext(),
      effect: (context, state, oldState, event, dispatch) {
        final _value = value(state);
        final bool _shouldUpdateOldValue;
        final bool _shouldTriggerEffect;
        if (event == null) {
          _shouldTriggerEffect = !skipInitialValue;
          _shouldUpdateOldValue = true;
        } else {
          final _oldValue = context.oldValue as Value;
          _shouldTriggerEffect = !_areEqual(_oldValue, _value);
          _shouldUpdateOldValue = _shouldTriggerEffect;
        }
        if (_shouldUpdateOldValue) {
          context.oldValue = _value;
        }
        if (_shouldTriggerEffect) {
          effect(_value, dispatch);
        }
      },
    );
  }

  /// Add `effect` triggered by react partial state value change,
  /// it will cancel previous effect when value changed.
  /// 
  /// [value] describe which part of value is observed.
  /// 
  /// [areEqual] describe how old value and new value are treat as equal (not change).
  /// 
  /// [skipInitialValue] is true if initial value is skipped and won't trigger effect,
  /// is false if initial value triggers effect, default is true.
  /// 
  /// [effect] describe side effect, if effect has cancellation mechanism,
  /// We can return a `Dispose` function contain the cancellation logic in effect callback.
  /// This `Dispose` will be called when value changed or system dispose is called.
  /// 
  System<State, Event> reactLatest<Value>({
    required Value Function(State state) value,
    AreEqual<Value>? areEqual,
    bool skipInitialValue = true,
    required Dispose? Function(Value value, Dispatch<Event> dispatch) effect,
  }) {
    final _areEqual = areEqual ?? defaultAreEqual;
    return withContext<_ReactLatestContext<Value, Event>>(
      createContext: () => _ReactLatestContext(),
      effect: (context, state, oldState, event, dispatch) {
        final reactContext = context.reactContext;
        final _value = value(state);
        final bool _shouldUpdateOldValue;
        final bool _shouldTriggerEffect;
        if (event == null) {
          _shouldTriggerEffect = !skipInitialValue;
          _shouldUpdateOldValue = true;
        } else {
          final _oldValue = reactContext.oldValue as Value;
          _shouldTriggerEffect = !_areEqual(_oldValue, _value);
          _shouldUpdateOldValue = _shouldTriggerEffect;
        }
        if (_shouldUpdateOldValue) {
          reactContext.oldValue = _value;
        }
        if (_shouldTriggerEffect) {
          final latestContext = context.latestContext;
          latestContext.disposePreviousEffect();
          latestContext.dispose = effect(_value, latestContext.versioned(dispatch));
        }
      },
      dispose: (context) {
        context.latestContext.disposePreviousEffect();
      },
    );
  }
}

class _ReactContext<Value> {
  Value? oldValue;
}

class _ReactLatestContext<Value, Event> {
  final _ReactContext<Value> reactContext = _ReactContext();
  final LatestContext<Event> latestContext = LatestContext();
}