import 'package:love/love.dart';

// typedef CounterState = int;

abstract class CounterEvent {}
class Increment implements CounterEvent {}
class Decrement implements CounterEvent {}

void main() async {
  
  final counterSystem = System<int, CounterEvent>
    .create(initialState: 0)
    .on<Increment>(
      reduce: (state, event) => state + 1,
      effect: (state, event, dispatch) async {
        await Future<void>.delayed(const Duration(seconds: 3));
        dispatch(Decrement());
      },
    )
    .on<Decrement>(
      reduce: (state, event) => state - 1,
    )
    .log()
    .reactState(
      effect: (state, dispatch) {
        print('Simulate persistence save call with state: $state');
      },
    )
    .onRun(effect: (initialState, dispatch) {
      dispatch(Increment());
      return null;
    },);
  
  final disposer = counterSystem.run();

  await Future<void>.delayed(const Duration(seconds: 6));

  disposer();
}