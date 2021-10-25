
import 'system.dart';
import 'on_on_system.dart';
import 'dart:core' as core; // resolve conflict with parameter 'system.log.print'

extension LogOperators<State, Event> on System<State, Event> {

  /// Add log `effect` to the system.
  /// 
  /// After apply this operator, system will print message when:
  /// * system run
  /// * system update state
  /// * system dispose
  /// 
  /// For example:
  /// 
  /// ```dart
  /// System<int, CounterEvent> createCounterSystem() { ... }
  ///
  /// void main() async {
  /// 
  ///   final counterSystem = createCounterSystem();
  /// 
  ///   final disposer = counterSystem
  ///     .log()  // --> add log effect
  ///     .run();
  ///   
  ///   await Future<void>.delayed(const Duration(seconds: 6));
  /// 
  ///   disposer();
  /// 
  /// } 
  /// ```
  /// 
  /// will log something like this:
  /// 
  /// ```
  /// System<int, CounterEvent> Run
  /// System<int, CounterEvent> Update {
  ///   event: null
  ///   oldState: null
  ///   state: 0
  /// }
  /// System<int, CounterEvent> Update {
  ///   event: Instance of 'Increment'
  ///   oldState: 0
  ///   state: 1
  /// }
  /// System<int, CounterEvent> Dispose
  /// ```
  /// If we want to replace the runtimeType `System<int, CounterEvent>` text with some 
  /// meaningful [label], we can use [label] parameter:
  /// 
  /// ```dart
  ///   counterSystem
  ///     .log(label: 'CounterSystem')
  ///     .run();
  /// ```
  /// 
  /// the output will become:
  /// 
   /// ```
  /// CounterSystem Run
  /// CounterSystem Update {
  ///   event: null
  ///   oldState: null
  ///   state: 0
  /// }
  /// CounterSystem Update {
  ///   event: Instance of 'Increment'
  ///   oldState: 0
  ///   state: 1
  /// }
  /// CounterSystem Dispose
  /// ```
  /// 
  /// By default `log` operator use built in `print` function (from ''dart:core'') to print message, 
  /// but we can provide custom [print] function (eg, `debugPrint`, `logger.log`) to replace it:
  /// 
  /// ```dart
  ///   counterSystem
  ///     .log(print: (message) => debugPrint(message))
  ///     .run();
  /// ```
  /// 
  /// The message will be print with `debugPrint` in the above example.
  /// 
  System<State, Event> log({
    core.String? label,
    void Function(core.String message)? print,
  }) {
    final _label = label ?? '$runtimeType';
    final _print = print ?? (core.String message) => core.print(message);
    return this
      .add(effect: (state, oldState, event, _) { 
        if (event == null) _print('$_label Run');
        _print('$_label Update {\n  event: $event\n  oldState: $oldState\n  state: $state\n}');
       })
      .onDispose(run: () {
        _print('$_label Dispose');
      });
  }
}