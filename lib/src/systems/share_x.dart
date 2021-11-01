import 'system.dart' show System;
import '../types/types.dart' show Disposer;
import '../forwarders/effect_forwarder.dart' show EffectForwarder;

extension ShareX<State, Event> on System<State, Event> {

  /// Share same source of truth using strategy `refCount`.
  /// 
  /// If `system.run` has been called multiple time, this operator will make them share same source of truth. 
  /// This operator use `refCount` strategy to dispose resource, 
  /// Which means the first run triggers source system run and when all running systems has been disposed, 
  /// then the source system will be disposed.
  /// 
  /// It's useful for some scoped system like `detailPageSystem`, 
  /// downward `run` will share same source of truth for this page only.
  /// The system can be run multiple times for different concerns (performance optimization),
  /// but they share same source of truth in this page.
  /// Another detail page has another source of truth that's the scoped means.
  /// 
  System<State, Event> share() => copy((run) {
    int count = 0;
    Disposer? sourceDisposer;
    EffectForwarder<State, Event>? forwarder;
    EffectForwarder<State, Event> getForwarder() => forwarder ??= EffectForwarder();
    
    return ({reduce, effect, interceptor}) {

      assert(reduce == null, 'downward `reduce` is not null in share context.');
      assert(interceptor == null, 'downward `interceptor` is not null in share context.');

      final nextEffect = effect ?? (_, __, ___, ____) {};
      final Disposer disposer = getForwarder().add(effect: nextEffect);
      count += 1;

      if (count == 1) {
        sourceDisposer = run(effect: getForwarder().effect);
      }

      return Disposer(() {
        disposer();
        count -= 1;
        if (count == 0) {
          sourceDisposer?.call();
          sourceDisposer = null;
          forwarder?.dispose();
          forwarder = null;
        }
      });
    };
  });

  /// Share same source of truth using strategy `forever`.
  /// 
  /// If `system.run` has been called multiple time, 
  /// this operator will make them share same source of truth. 
  /// The source system will be running forever after first run get called, 
  /// Which means even all running system's has been disposed, 
  /// The source system will not be disposed either.
  /// 
  /// It's useful for some global shared system, like `appSystem`.
  /// 
  System<State, Event> shareForever() => copy((run) {
    final forwarder = EffectForwarder<State, Event>();
    bool running = false;
    return ({reduce, effect, interceptor}) {
      assert(reduce == null, 'downward `reduce` is not null in share context.');
      assert(interceptor == null, 'downward `interceptor` is not null in share context.');
      
      final nextEffect = effect ?? (_, __, ___, ____) {};
      final Disposer disposer = forwarder.add(effect: nextEffect);

      if (!running) {
        running = true;
        run(effect: forwarder.effect);
      }
      
      return disposer;
    };
  });
}