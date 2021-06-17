import '../types/types.dart';
import 'effect_system.dart';
import '../systems/rx_on_system.dart';

extension EffectSystemRxOperators<State, Event> on EffectSystem<State, Event> {

  /// Stream version of `add(effect: )`.
  /// 
  /// `Moment` holds state, oldState and event of that
  /// moment. `moments` is stream of moment when event happen.
  /// 
  /// This code:
  /// 
  ///```dart 
  ///  ...
  ///  .effects((moments) => moments
  ///    .asyncExpand((moment) async* {
  ///      if (moment.event == 520) {
  ///        yield 521;
  ///      }
  ///    })
  ///  );
  /// ```
  /// will produce same result as this:
  /// 
  /// ```dart
  ///  ...
  ///  .add(effect: (state, oldState, event, dispatch) {
  ///    if (event == 520) {
  ///      dispatch(521);
  ///    }
  ///  },);
  /// ```
  /// 
  EffectSystem<State, Event> effects(
    Stream<Event> Function(Stream<Moment<State, Event>> moments) effects
  ) => forward(copy: (system) => system.effects(effects));
}