import 'types.dart' show Dispatch, Disposer;

class LatestContext<Event> {

  Object? _identifier;
  Disposer? _disposer;

  set disposer(Disposer? disposer) {
    _disposer = Disposer(() {
      disposer?.call();
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
    if (_disposer != null) {
      _disposer?.call();
      _disposer = null;
    }
  }
}
