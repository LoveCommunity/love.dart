
/// `Optional` is the same as nullable except it can handle nested cases like `Optional<Optional<int>>`.
abstract class Optional<T> {}

class OptionalNone<T> implements Optional<T> {}
class OptionalValue<T> implements Optional<T> {
  OptionalValue(this.value);
  final T value;
}