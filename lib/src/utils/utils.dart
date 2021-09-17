import '../types/types.dart';

R? safeAs<T, R>(T value) => value is R ? value : null;

Reduce<State, Event>? combineReduce<State, Event>(
  Reduce<State, Event>? reduce,
  Reduce<State, Event>? nextReduce,
) {
  return _combine(
    reduce,
    nextReduce,
    combine: (reduce, nextReduce) {
      return (state, event) => nextReduce(reduce(state, event), event); 
  });
}

Effect<State, Event>? combineEffect<State, Event>(
  Effect<State, Event>? effect,
  Effect<State, Event>? nextEffect,
) {
  return _combine(
    effect, 
    nextEffect, 
    combine: (effect, nextEffect) {
     return (oldState, event, state, dispatch) {
      effect(oldState, event, state, dispatch);
      nextEffect(oldState, event, state, dispatch);
    };
  });
}

T? _combine<T>(
  T? it1, 
  T? it2, {
  required T Function(T, T) combine,
}) {
  if (it1 != null && it2 != null) {
    return combine(it1, it2);
  } else if (it1 != null && it2 == null) {
    return it1;
  } else if (it1 == null && it2 != null) {
    return it2;
  } else {
    return null;
  }
}