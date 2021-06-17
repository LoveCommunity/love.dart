import 'effect_system.dart';
import '../types/types.dart';
import '../forwarders/effect_forwarder.dart';

extension EffectSystemShareOperators<State, Event> on EffectSystem<State, Event> {

  /// Share same source of truth using stretegy `refCount`.
  /// 
  /// If `system.run` has been called mutiple time, this operator will make them share same source of truth. 
  /// This operator use `refCount` strategy to dispose resource, 
  /// Which means the first run triggers source system run and when all running systems has been disposed, 
  /// then the source system will be disposed.
  /// 
  /// It's useful for some scoped system like `detailPageSystem`, 
  /// Downside `run` will share same source of truth for this page only.
  /// The system can be runned mutiple times for different concerns (performance optimization),
  /// but they share same source of turth in this page.
  /// Another detail page has another source of truth that's the scoped means.
  /// 
  EffectSystem<State, Event> share() => copy((run) {
    final forwarder = EffectForwarder<State, Event>();
    int count = 0;
    Dispose? sourceDispose;
    return ({effect}) {
      final nextEffect = effect ?? (_, __, ___, ____) {};
      final Dispose dispose = forwarder.add(effect: nextEffect);
      count += 1;

      if (count == 1) {
        sourceDispose = run(effect: forwarder.effect);
      }

      return Dispose(() {
        dispose();
        count -= 1;
        if (count == 0 && sourceDispose != null) {
          sourceDispose?.call();
          sourceDispose = null;
        }
      });
    };
  });

  /// Share same source of truth using stretegy `forever`.
  /// 
  /// If `system.run` has been called mutiple time, 
  /// this operator will make them share same source of truth. 
  /// The source system will be running forever after first run get called, 
  /// Which means even all running system's has been disposed, 
  /// The source system will not be disposed either.
  /// 
  /// It'a useful for some global shared system, like `appSystem`.
  /// 
  EffectSystem<State, Event> shareForever() => copy((run) {
    final forwarder = EffectForwarder<State, Event>();
    bool running = false;
    return ({effect}) {
      final nextEffect = effect ?? (_, __, ___, ____) {};
      final Dispose dispose = forwarder.add(effect: nextEffect);

      if (!running) {
        running = true;
        run(effect: forwarder.effect);
      }
      
      return dispose;
    };
  });
}