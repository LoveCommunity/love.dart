class TestContext {
  int invoked = 0;
  List<String> stateParameters = [];
  List<String?> oldStateParameters = [];
  List<String?> eventParameters = [];
  bool isDisposed = false;
}