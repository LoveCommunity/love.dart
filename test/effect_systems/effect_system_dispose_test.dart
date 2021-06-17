
import 'package:test/test.dart';
import 'package:love/love.dart';

void main() {

  test('EffectSystem.dispose', () {
    int disposeCount = 0;
    final system = EffectSystem<String, String>.pure(({effect}) {
      return Dispose(() => disposeCount += 1);
    });
    final dispose = system.run();
    expect(disposeCount, 0);
    dispose();
    expect(disposeCount, 1);
    dispose();
    expect(disposeCount, 1);
  });
}