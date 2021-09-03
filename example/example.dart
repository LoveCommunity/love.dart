import 'package:love/love.dart';

// typedef CounterState = int;

abstract class CounterEvent {}
class CounterEventIncrease implements CounterEvent {}
class CounterEventDecrease implements CounterEvent {}

void main() async {
  
  final counterSystem = System<int, CounterEvent>
    .create(initialState: 0)
    .on<CounterEventIncrease>(
      reduce: (state, event) => state + 1,
      effect: (state, event, dispatch) async {
        await Future<void>.delayed(Duration(seconds: 3));
        dispatch(CounterEventDecrease());
      },
    )
    .on<CounterEventDecrease>(
      reduce: (state, event) => state - 1,
    )
    .add(effect: (state, oldState, event, dispatch) {
      print('\nEvent: $event');
      print('State: $state');
      print('OldState: $oldState');
    })
    .reactState(
      effect: (state, dispatch) {
        print('Simulate persistence save call with state: $state');
      },
    )
    .onRun(effect: (initialState, dispatch) {
      dispatch(CounterEventIncrease());
    },);
  
  final dispose = counterSystem.run();

  await Future<void>.delayed(Duration(seconds: 3));

  dispose();
}