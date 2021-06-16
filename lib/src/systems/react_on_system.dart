import 'system.dart';
import '../types/types.dart';
import '../types/optional.dart';

extension ReactOperators<State, Event> on System<State, Event> {

  /// State based version of `add(effect: )`.
  /// 
  /// Conceptually, this effect is triggered based on state change.
  /// This is same as `add(effect: )` except it ignored `event` parameter.
  System<State, Event> reactState({
    required void Function(State state, State? oldState, Dispatch<Event> dispatch) effect,
  }) => add(
    effect: (state, oldState, event, dispatch) {
      effect(state, oldState, dispatch);
    }
  );

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
  System<State, Event> react<Value>({
    required Value Function(State state) value,
    AreEqual<Value>? areEqual,
    bool skipFirstValue = false,
    required void Function(Value value, Dispatch<Event> dispatch) effect,
  }) => _reactRequest(
    test: (state) => OptionalValue(value(state)),
    areEqual: areEqual,
    skipFirstRequest: skipFirstValue,
    effect: effect,
  );

  System<State, Event> _reactRequest<Request>({
    required Optional<Request> Function(State state) test,
    AreEqual<Request>? areEqual,
    bool skipFirstRequest = false,
    required void Function(Request request, Dispatch<Event> dispatch) effect,
  }) => withContext<_RequestContext<Request, Event>>(
    createContext: () => _RequestContext(
      skipRequestOnce: skipFirstRequest
    ),
    effect: (context, state, oldState, event, dispatch) {
      final request = test(state);
      final oldRequest = context.oldRequest;
      final changed = _optinalChanged(
        oldValue: oldRequest,
        value: request,
        areEqual: areEqual
      );
      if (changed) {
        context.oldRequest = request;
        if (request is OptionalValue<Request>) {
          if (context.skipRequestOnce) {
            context.skipRequestOnce = false;
            return;
          }
          effect(request.value, dispatch);
        }
      }
    },
  );
}

class _RequestContext<Request, Event> {
  _RequestContext({
    required this.skipRequestOnce,
  });
  bool skipRequestOnce;
  Optional<Request> oldRequest = OptionalNone();
}

bool _optinalChanged<Value>({
  required Optional<Value> oldValue,
  required Optional<Value> value,
  AreEqual<Value>? areEqual,
}) {
  final AreEqual<Value> _areEqual = areEqual ?? (it1, it2) => it1 == it2;
  if (oldValue is OptionalValue<Value> && value is OptionalValue<Value>) {
    return !_areEqual(oldValue.value, value.value);
  } else if (oldValue is OptionalNone<Value> && value is OptionalValue<Value>) {
    return true;
  } else if (oldValue is OptionalValue<Value> && value is OptionalNone<Value>) {
    return true;
  } else {
    return false;
  }
}