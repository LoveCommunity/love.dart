import 'system.dart';
import '../effect_systems/effect_system.dart';
import '../effect_systems/share_on_effect_system.dart';

extension ShareOperators<State, Event> on System<State, Event> {

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
  EffectSystem<State, Event> share() => asEffectSystem()
    .share();

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
  EffectSystem<State, Event> shareForever() => asEffectSystem()
    .shareForever();
}