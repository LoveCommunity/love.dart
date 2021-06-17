import '../types/types.dart';
import '../systems/system.dart';

class EffectSystem<State, Event> {

  EffectSystem._raw(this._system);

  final System<State, Event> _system;

  /// Create a EffectSystem with underlying run function.
  /// 
  /// It can be used when we has custom run logic. 
  /// Like Mock `EffectSystem` that is used for testing purpose.
  EffectSystem.pure(EffectSystemRun<State, Event> run):
    this._raw(System.pure(_toSystemRun(run)));

  /// Run the system.
  /// 
  /// Return a Dispose function to stop system later.
  Dispose run({
    Effect<State, Event>? effect,
  }) => _system.run(effect: effect);

  /// Create an effect system with initail state and `reduce`.
  EffectSystem.create({
    required State initialState,
    required Reduce<State, Event> reduce,
  }): this._raw(System<State, Event>
    .create(initialState: initialState)
    .add(reduce: reduce));

  /// Forward operation to underlying `System`.
  EffectSystem<State, Event> forward({
    required CopySystem<State, Event> copy,
  }) {
    final next = copy(_system);
    return EffectSystem._raw(next);
  }
}

Run<State, Event> _toSystemRun<State, Event>(
  EffectSystemRun<State, Event> effectSystemRun
) => ({reduce, effect}) => effectSystemRun(effect: effect);