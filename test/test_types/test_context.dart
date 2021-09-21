class TestContext {
  int invoked = 0;
  final List<String> stateParameters = [];
  final List<String?> oldStateParameters = [];
  final List<String?> eventParameters = [];
  bool isDisposed = false;
}