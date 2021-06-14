import 'types.dart';

class LatestContext<Event> {

  int _version = 0;
  Dispose? _dispose;

  void set dispose(Dispose? dispose) {
    _dispose = Dispose(() {
      dispose?.call();
      _version += 1;
    });
  }

  Dispatch<Event> versioned(Dispatch<Event> dispatch) {
    final _thisVersion = _version;
    return Dispatch((event) {
      if (_thisVersion == _version) {
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
