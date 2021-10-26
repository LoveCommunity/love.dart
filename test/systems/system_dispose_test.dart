import 'package:test/test.dart';
import 'package:love/love.dart';

void main() {

  test('System.disposer', () async {
    int disposeCounts = 0;
    final system = System<String, String>
      .pure(({effect, reduce, interceptor}) {
        return Disposer(() => disposeCounts += 1);
      });

    final disposer = system.run();
    expect(disposeCounts, 0);
    disposer();
    expect(disposeCounts, 1);
    disposer();
    expect(disposeCounts, 1);
  });
}