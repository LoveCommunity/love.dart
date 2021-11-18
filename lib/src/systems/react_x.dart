import 'system.dart' show System;
import '../types/types.dart' show Dispatch, Disposer, Equals;
import '../types/latest_context.dart' show LatestContext;
import '../utils/default_equals.dart' show defaultEquals;

extension ReactX<State, Event> on System<State, Event> {

  /// Add `effect` triggered by reacting to whole state change.
  /// 
  /// ## API Overview
  /// 
  /// ```dart
  /// system
  ///   ...
  ///   .reactState(
  ///     equals: (it1, it2) {  // `equals` is used to determine if old state equals 
  ///       return it1 == it2;  // to new state. If there are not equal, then effect
  ///     },                    // is triggered. `equals` is nullable, defaults to 
  ///                           // `==` as shown.
  ///     skipInitialState: true, // return true if initial state is skipped,
  ///                             // which won't trigger effect.
  ///                             // return false if initial state isn't skipped,
  ///                             // which will trigger effect.
  ///                             // `skipInitialState` defaults to true if omitted.
  ///     effect: (state, dispatch) { 
  ///       // trigger effect here with new state, required
  ///     },
  ///   )
  ///   ...
  /// ```
  /// 
  /// ## Usage Example
  /// 
  /// Below code showed how to save state when state changed.
  /// 
  /// ```dart
  /// system
  ///   ...
  ///   .reactState(
  ///     effect: (state, dispatch) async {
  ///       await storage.save(state);
  ///     },
  ///   )
  ///   ...
  /// ```
  /// 
  System<State, Event> reactState({
    Equals<State>? equals,
    bool skipInitialState = true,
    required void Function(State state, Dispatch<Event> dispatch) effect,
  }) => react<State>(
    value: (state) => state,
    equals: equals,
    skipInitialValue: skipInitialState,
    effect: effect
  );

  /// Add `effect` triggered by reacting to state's partial value change.
  /// 
  /// ## API Overview
  /// 
  /// ```dart
  /// system
  ///   ...
  ///   .react<int>(
  ///     value: (state) => state.itemId, // map state to value, required
  ///     equals: (value1, value2) {  // `equals` is used to determine if old value equals 
  ///       return value1 == value2;  // to new value. If there are not equal, then effect
  ///     },                          // is triggered. `equals` is nullable, defaults to 
  ///                                 // `==` as shown.
  ///     skipInitialValue: true, // return true if initial value is skipped,
  ///                             // which won't trigger effect.
  ///                             // return false if initial value isn't skipped,
  ///                             // which will trigger effect.
  ///                             // `skipInitialValue` defaults to true if omitted.
  ///     effect: (value, dispatch) { 
  ///       // trigger effect here with new value, required
  ///     },
  ///   )
  ///   ...
  /// ```
  /// 
  /// ## Usage Example
  /// 
  /// Below code showed how to send account changed event to analytics service,
  /// when user id changed.
  /// 
  /// ```dart
  /// system
  ///   ...
  ///   .react<String?>(
  ///     value: (state) => state.userId,
  ///     effect: (userId, dispatch) async {
  ///       await analyticsService.onAccountChanged(userId);
  ///     },
  ///   )
  ///   ...
  /// ```
  System<State, Event> react<Value>({
    required Value Function(State state) value,
    Equals<Value>? equals,
    bool skipInitialValue = true,
    required void Function(Value value, Dispatch<Event> dispatch) effect,
  }) {
    final _equals = equals ?? defaultEquals;
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
          _shouldTriggerEffect = !_equals(_oldValue, _value);
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

  /// Add `effect` triggered by react state's partial value change,
  /// it will cancel previous effect when new effect triggered or system
  /// disposal.
  /// 
  /// ## API Overview
  /// 
  /// ```dart
  /// searchSystem
  ///   ...
  ///   .reactLatest<String>(
  ///     value: (state) => state.keyword, // map state to value, required
  ///     equals: (value1, value2) {  // `equals` is used to determine if old value equals 
  ///       return value1 == value2;  // to new value. If there are not equal, then effect
  ///     },                          // is triggered. `equals` is nullable, defaults to 
  ///                                 // `==` as shown.
  ///     skipInitialValue: true, // return true if initial value is skipped,
  ///                             // which won't trigger effect.
  ///                             // return false if initial value isn't skipped,
  ///                             // which will trigger effect.
  ///                             // `skipInitialValue` defaults to true if omitted.
  ///     effect: (value, dispatch) { 
  ///       // trigger effect here with new value, required
  ///       return Disposer(() { // return a `Disposer` to register cancel logic 
  ///                            // with this ticket.
  ///                            // return null or omit return, if there is nothing
  ///                            // to cancel.
  ///       });
  ///     },
  ///   )
  ///   ...
  /// ```
  /// 
  /// ## Usage Example
  /// 
  /// Below code showed how to model search bar, latest search words 
  /// cancel previous search API call if previous one is not completed.
  /// 
  /// ```dart
  /// searchSystem
  ///   ...
  ///   .reactLatest<String>(
  ///     value: (state) => state.keyword,
  ///     effect: (keyword, dispatch) async {
  ///       try {
  ///         final data = await api.call(keyword);
  ///         dispatch(LoadDataSuccess(data));
  ///       } on Exception {
  ///         dispatch(LoadDataError());
  ///       }
  ///     },
  ///   )
  /// ```
  /// 
  /// For this scenario if previous search result came after latest one, 
  /// the previous result will be ignored.
  /// 
  /// If search `api` provide a cancellation mechanism, 
  /// We can return a `Disposer` to register cancel logic with this ticket.
  /// 
  /// For example if above `api.call` return `Stream`:
  ///
  /// ```dart
  /// searchSystem
  ///   ...
  ///   .reactLatest<String>(
  ///     value: (state) => state.keyword,
  ///     effect: (keyword, dispatch) async {
  ///       final stream = api.call(keyword); // it return stream now
  ///       final subscription = stream.listen(
  ///         (data) => dispatch(LoadDataSuccess(data)),
  ///         onError: (Object _) => dispatch(LoadDataError()),
  ///       );
  ///       return Disposer(() => subscription.cancel()); // register cancel
  ///     },
  ///   )
  ///   ... 
  /// ```
  /// 
  /// This `Disposer` will be called when keyword changed or system disposal.
  /// 
  System<State, Event> reactLatest<Value>({
    required Value Function(State state) value,
    Equals<Value>? equals,
    bool skipInitialValue = true,
    required Disposer? Function(Value value, Dispatch<Event> dispatch) effect,
  }) {
    final _equals = equals ?? defaultEquals;
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
          _shouldTriggerEffect = !_equals(_oldValue, _value);
          _shouldUpdateOldValue = _shouldTriggerEffect;
        }
        if (_shouldUpdateOldValue) {
          reactContext.oldValue = _value;
        }
        if (_shouldTriggerEffect) {
          final latestContext = context.latestContext;
          latestContext.disposePreviousEffect();
          latestContext.disposer = effect(_value, latestContext.versioned(dispatch));
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