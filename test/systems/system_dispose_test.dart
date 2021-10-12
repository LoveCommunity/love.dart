import 'package:test/test.dart';
import 'package:love/love.dart';

void main() {

  test('System.dispose', () async {
    int disposeCounts = 0;
    final system = System<String, String>
      .pure(({effect, reduce, interceptor}) {
        return Dispose(() => disposeCounts += 1);
      });

    final dispose = system.run();
    expect(disposeCounts, 0);
    dispose();
    expect(disposeCounts, 1);
    dispose();
    expect(disposeCounts, 1);
  });
}