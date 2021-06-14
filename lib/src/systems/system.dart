import '../types/types.dart';

class System<State, Event> {

  /// Create a System with underlinying run function.
  /// 
  /// It can be used when we has custom run logic. 
  /// Like Mock `System` that is used for testing purpose.
  System.pure(this._run);

  final Run<State, Event> _run;

  /// Run the system.
  /// 
  /// Return a Dispose function to stop system later.
  Dispose run({
    Reduce<State, Event>? reduce,
    Effect<State, Event>? effect,
  }) {
    var isDisposed = false;
    final dispose = _run(
      reduce: reduce,
      effect: effect,
    );
    return Dispose(() {
      if (isDisposed) return;
      isDisposed = true;
      dispose();
    });
  }
}