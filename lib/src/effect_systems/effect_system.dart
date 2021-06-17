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

  /// Create a new effect system based on current one.
  /// 
  /// Return a redefined effect system by copy a new one with custom logic.
  /// The concept is similar to `middleware` or `interceptor`.
  EffectSystem<State, Event> copy(
    CopyEffectSystemRun<State, Event> copy
  ) {
    final _copy = _toCopySystem(copy);
    return forward(copy: _copy);
  }

  /// Create a new effect system with a Context.
  /// 
  /// Return a new effect system with some "live data" accotiated with it.
  EffectSystem<State, Event> runWithContext<Context>({
    required Context Function() createContext,
    required Dispose Function(Context context, EffectSystemRun<State, Event> run, Effect<State, Event>? nextEffect) run,
  }) => forward(copy: (system) => system.runWithContext<Context>(
    createContext: createContext,
    run: (context, systemRun, nextReduce, nextEffect) {
      final effectSystemRun = _toEffectSystemRun(systemRun);
      return run(context, effectSystemRun, nextEffect);
    },
  ));

  /// Create a new effect system with a Context.
  /// 
  /// Return a new effect system with some "live data" accotiated with it.
  EffectSystem<State, Event> withContext<Context>({
    required Context Function() createContext,
    required ContextEffect<Context, State, Event> effect,
    void Function(Context context)? dispose,
  }) => forward(copy: (system) => system.withContext(
    createContext: createContext,
    effect: effect,
    dispose: dispose,
  ));

  /// Add `effect` to the effect system.
  EffectSystem<State, Event> add({
    required Effect<State, Event> effect
  }) => forward(copy: (system) => system.add(
    effect: effect
  ));
}

CopySystem<State, Event> _toCopySystem<State, Event>(
  CopyEffectSystemRun<State, Event> copy
) => (system) => system.copy((run) {
  final _run = _toEffectSystemRun(run);
  final _next = copy(_run);
  return ({reduce, effect}) => _next(effect: effect);
});

EffectSystemRun<State, Event> _toEffectSystemRun<State, Event>(
  Run<State, Event> run
) => ({effect}) => run(effect: effect);

Run<State, Event> _toSystemRun<State, Event>(
  EffectSystemRun<State, Event> effectSystemRun
) => ({reduce, effect}) => effectSystemRun(effect: effect);