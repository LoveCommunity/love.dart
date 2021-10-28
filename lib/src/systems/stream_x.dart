import 'dart:async';

import 'system.dart';
import '../types/types.dart';

extension StreamX<State, Event> on System<State, Event> {

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
  System<State, Event> effects(
    Stream<Event> Function(Stream<Moment<State, Event>> moments) effects
  ) => withContext<_Context<State, Event>>(
    createContext: () => _Context(
      StreamController(),
    ),
    effect: (context, state, oldState, event, dispatch) {
      if (event == null) {
        final events = effects(context.moments.stream);
        context.subscription = events.listen(dispatch.call);
      }
      context.moments.add(Moment(state, oldState, event));
    },
    dispose: (context) {
      context.subscription?.cancel();
      context.subscription = null;
      context.moments.close();
    },
  );
}

class _Context<State, Event> {
  _Context(this.moments);
  final StreamController<Moment<State, Event>> moments;
  StreamSubscription<Event>? subscription;
}