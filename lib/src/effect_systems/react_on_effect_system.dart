import 'effect_system.dart';
import '../systems/react_on_system.dart';
import '../types/types.dart';

extension EffectSystemReactOperators<State, Event> on EffectSystem<State, Event> {

  /// Add `effect` triggered by react partial state value change.
  /// 
  /// [value] describe which part of value is observed.
  /// 
  /// [areEqual] describe how old value and new value are treat as equal (not change).
  /// 
  /// [skipFirstValue] is false if first value will trigger the effect, 
  /// is ture if first value won't trigger effect, default is false.  
  ///
  /// [effect] describe side effect. 
  EffectSystem<State, Event> react<Value>({
    required Value Function(State state) value,
    AreEqual<Value>? areEqual,
    bool skipFirstValue = false,
    required void Function(Value value, Dispatch<Event> dispatch) effect,
  }) => forward(copy: (system) => system.react(
    value: value,
    areEqual: areEqual,
    skipFirstValue: skipFirstValue,
    effect: effect,
  ));

  /// Add `effect` triggered by react partial state value change,
  /// it will cancel previous effect when value changed.
  /// 
  /// [value] describe which part of value is observed.
  /// 
  /// [areEqual] describe how old value and new value are treat as equal (not change).
  /// 
  /// [skipFirstValue] is false if first value triggers the effect, 
  /// is ture if first value won't trigger effect, default is false.
  /// 
  /// [effect] describe side effect, if effect has cancellation mechanism,
  /// We can return a `Dispose` function contain the cancellation logic in effect callback.
  /// This `Dispose` will be called when value changed or system dispose is called.
  /// 
  EffectSystem<State, Event> reactLatest<Value>({
    required Value Function(State state) value,
    AreEqual<Value>? areEqual,
    bool skipFirstValue = false,
    required Dispose? Function(Value value, Dispatch<Event> dispatch) effect,
  }) => forward(copy: (system) => system.reactLatest(
    value: value,
    areEqual: areEqual,
    skipFirstValue: skipFirstValue,
    effect: effect,
  ));

  /// Add `effect` triggered by a request which is computed from state.
  /// 
  /// Every time state changed, a request is computed from state, 
  /// if a fresh request is computed, the effect will be triggered by this request.
  /// Fresh request means newRequest is not null and newRequest are not equal to oldRequest. 
  /// 
  /// [request] describe how request is computed from state. 
  /// return null if there is no request.
  /// 
  /// [areEqual] describe how old request and new request are treat as equal (not change).
  /// 
  /// [skipFirstRequest] is false if first request will trigger the effect, 
  /// is ture if first request won't trigger effect, default is false.  
  /// 
  /// [effect] describe side effect.
  ///  
  EffectSystem<State, Event> reactRequest<Request>({
    required Request? Function(State state) request,
    AreEqual<Request>? areEqual,
    bool skipFirstRequest = false,
    required void Function(Request request, Dispatch<Event> dispatch) effect,
  }) => forward(copy: (system) => system.reactRequest(
    request: request,
    areEqual: areEqual,
    skipFirstRequest: skipFirstRequest,
    effect: effect,
  ));

  /// Add `effect` triggered by a request which is computed from state,
  /// it will cancel previous effect when request changed.
  /// 
  /// Every time state changed, a request is computed from state, 
  /// if a fresh request is computed, the effect will be triggered by this request.
  /// Fresh request means newRequest is not null and newRequest are not equal to oldRequest. 
  /// 
  /// [request] describe how request is computed from state. 
  /// return null if there is no request.
  /// 
  /// [areEqual] describe how old request and new request are treat as equal (not change).
  /// 
  /// [skipFirstRequest] is false if first request will trigger the effect, 
  /// is ture if first request won't trigger effect, default is false.  
  ///  
  /// [effect] describe side effect, if effect has cancellation mechanism,
  /// We can return a `Dispose` function contain the cancellation logic in effect callback.
  /// This `Dispose` will be called when request changed or system dispose is called.
  /// 
  EffectSystem<State, Event> reactLatestRequest<Request>({
    required Request? Function(State state) request,
    AreEqual<Request>? areEqual,
    bool skipFirstRequest = false,
    required Dispose? Function(Request request, Dispatch<Event> dispatch) effect,
  }) => forward(copy: (system) => system.reactLatestRequest(
    request: request,
    areEqual: areEqual,
    skipFirstRequest: skipFirstRequest,
    effect: effect,
  ));
}