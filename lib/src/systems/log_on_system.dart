
import 'system.dart';
import 'on_on_system.dart';
import 'dart:core' as core; // resolve conflict with parameter 'system.log.print'

extension LogOperator<State, Event> on System<State, Event> {

  System<State, Event> log({
    core.String? label,
    void Function(core.String message)? print,
  }) {
    final _label = label ?? '$runtimeType';
    final _print = print ?? (core.String message) => core.print(message);
    return this
      .onRun(effect: (initialState, _) { 
        _print('$_label Run');
       })
      .add(effect: (state, oldState, event, _) { 
        _print('$_label Update {\n  event: $event\n  oldState: $oldState\n  state: $state\n}');
       })
      .onDispose(run: () {
        _print('$_label Dispose');
      });
  }
}