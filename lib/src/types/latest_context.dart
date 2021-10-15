import 'types.dart';

class LatestContext<Event> {

  Object? _identifier;
  Dispose? _dispose;

  void set dispose(Dispose? dispose) {
    _dispose = Dispose(() {
      dispose?.call();
      _identifier = null;
    });
  }

  Dispatch<Event> versioned(Dispatch<Event> dispatch) {
    final identifier = Object();
    _identifier = identifier;
    return Dispatch((event) {
      if (identical(identifier, _identifier)) {
        dispatch(event);
      }
    });
  }

  void disposePreviousEffect() {
    if (_dispose != null) {
      _dispose?.call();
      _dispose = null;
    }
  }
}
