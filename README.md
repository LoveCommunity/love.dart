# love

A state management library that is declarative, predictable and elegant.

![][love_overview_diagram]

## Why

**love** has DNA of [ReactiveX], [Redux] and [RxFeedback]. so it is:

* Unified - one is all, all is one (System<State, Event>)
* Declarative - system are first declared, effects begin after run is called
* Predictable - unidirectional data flow
* Flexible - scale well with complex app
* Elegant - code is clean for human to read and write
* Testable - system can be test straightforward

## Libraries

* [love] - dart only state management library. if we are developing pure dart app, we can [install love]
* [flutter_love] - provide flutter widgets handle common use case with [love]. if we are developing flutter app, we can [install flutter_love]

## Counter Example

```dart

// typedef CounterState = int;

abstract class CounterEvent {}
class Increment implements CounterEvent {}
class Decrement implements CounterEvent {}

void main() async {

  final counterSystem = System<int, CounterEvent>
    .create(initialState: 0)
    .add(reduce: (state, event) {
      if (event is Increment) return state + 1;
      return state;
    })
    .add(reduce: (state, event) {
      if (event is Decrement) return state - 1;
      return state;
    })
    .add(effect: (state, oldState, event, dispatch) {
      // effect - log update
      print('\nEvent: $event');
      print('OldState: $oldState');
      print('State: $state');
    })
    .add(effect: (state, oldState, event, dispatch) {
      // effect - inject mock events
      if (event == null) { // event is null on system run
        dispatch(Increment());
      }
    });

  final dispose = counterSystem.run();

  await Future<void>.delayed(const Duration(seconds: 6));

  dispose();
}

```

Output:

```

Event: null
OldState: null
State: 0

Event: Instance of 'Increment'
OldState: 0
State: 1
```

We hope the code is self explained. If you can guess what this code works for. That's very nice! 

This example first declare a counter system, state is the counts, events are `increment` and `decrement`. Then we run the system to log output, after 6 seconds we stop this system. 

The code is not very elegant for now, we have better way to approach same thing. We'll refactor code step by step when we get new skill. We keep it this way, because it's a good start point to demonstrates how it works.

## How it works?

![][love_detail_diagram]

## State

**State is data snapshot of a moment.**

For Example, the Counter State is counts:

```dart
// typedef CounterState = int;
```

## Event

**Event is description of what happened.**

For Example, the Counter Event is `increment` and `decrement` which describe what happened:

```dart
abstract class CounterEvent {}
class Increment implements CounterEvent {}
class Decrement implements CounterEvent {}
```

## Reduce

**Reduce is a function describe how state update when event happen.**

```dart
typedef Reduce<State, Event> = State Function(State state, Event event);
```

Counter Example:

```dart
    ...
    .add(reduce: (state, event) {
      if (event is Increment) return state + 1;
      return state;
    })
    .add(reduce: (state, event) {
      if (event is Decrement) return state - 1;
      return state;
    })
    ...
```

If `increment` event happen we increase the counts, if `decrement` event happen we decrease the counts.

We can make it cleaner:

```diff
    ...
-   .add(reduce: (state, event) {
-     if (event is Increment) return state + 1;
-     return state;
-   })
-   .add(reduce: (state, event) {
-     if (event is Decrement) return state - 1;
-     return state;
-   })
+   .on<Increment>(
+     reduce: (state, event) => state + 1,
+   )
+   .on<Decrement>(
+     reduce: (state, event) => state - 1,
+   )
    ...
```

It's more elegant for us to read and write.

Note: Reduce is pure function that only purpose is to compute a new state with current state and event. There is no side effect in this function.

Then, how to approach side effect?

## Effect

**Effect is a function that cause observable effect outside.**


```dart
typedef Effect<State, Event> = void Function(State state, State? oldState, Event? event, Dispatch<Event> dispatch);
```

**Side Effects**:
  * Presentation
  * Log
  * Networking
  * Persistence
  * Analytics
  * Bluetooth
  * Timer
  * ...

Bellow are `log effect` and `mock effect`:

```dart
    ...
    .add(effect: (state, oldState, event, dispatch) {
      // effect - log update
      print('\nEvent: $event');
      print('OldState: $oldState');
      print('State: $state');
    })
    .add(effect: (state, oldState, event, dispatch) {
      // effect - inject mock events
      if (event == null) { // event is null on system run
        dispatch(Increment());
      }
    });
```

Then, what about async stuff like `networking effect` or `timer effect`:

```diff
    ...
    .add(effect: (state, oldState, event, dispatch) {
      // effect - log update
      ...
    })
+   .add(effect: (state, oldState, event, dispatch) async {
+     // effect - auto decrease via async event
+     if (event is Increment) {
+       await Future<void>.delayed(const Duration(seconds: 3));
+       dispatch(Decrement());
+     }
+   })
    ...
```

We've add a `timer effect`, when an `increment` event happen, we'll dispatch a `decrement` event after 3 seconds to restore the counts.

We can also add `persistence effect`:

```diff
    ...
    .add(effect: (state, oldState, event, dispatch) async {
      // effect - auto decrease via async event
      ...
    })
+   .add(effect: (state, oldState, event, dispatch) {
+     // effect - persistence
+     if (event != null  // exclude initial state
+       && oldState != state // trigger only when state changed
+     ) {
+       print('Simulate persistence save call with state: $state');
+     }
+   },)
    ...

```

This persistence save function will be called when state changed, but initial state is skipped since most of time initial state is restored from persistence layer, there is no need to save it back again. 

## High Level Effect Operator

We've introduced how to add `log` effect:

```dart
    ...
    .add(effect: (state, oldState, event, dispatch) {
      print('\nEvent: $event');
      print('OldState: $oldState');
      print('State: $state');
    })
    ...
```

Output:

```
Event: null
OldState: null
State: 0

Event: Instance of 'Increment'
OldState: 0
State: 1
```

Because `log` is a common effect, this library provide built-in `log` operator to address it:

```diff
    ...
-   .add(effect: (state, oldState, event, dispatch) {
-     print('\nEvent: $event');
-     print('OldState: $oldState');
-     print('State: $state');
-   })
+   .log()
    ...
```

Output becomes:

```
System<int, CounterEvent> Run
System<int, CounterEvent> Update {
  event: null
  oldState: null
  state: 0
}
System<int, CounterEvent> Update {
  event: Instance of 'Increment'
  oldState: 0
  state: 1
}
System<int, CounterEvent> Dispose
```

As we see, `log` operator can do more with less code, it not only log `updates`, but also log system `run` and `dispose` which maybe helpful for debug.

`log` is a **scene focused operator** which scale the log demand followed with a detailed solution. If we are **repeatedly write similar code to solve similar problem**. Then we can **extract operators for reusing solution**. `log` is one of these operators.

## Effect Trigger

We've added `timer effect` and `persistence effect`. For now, Instead of thinking what effect is it, let's focus on what **triggers** these effects:

```dart
    ...
    .add(effect: (state, oldState, event, dispatch) async {
      // effect - auto decrease via async event
      if (event is Increment) {
        await Future<void>.delayed(const Duration(seconds: 3));
        dispatch(Decrement());
      }
    })
    .add(effect: (state, oldState, event, dispatch) {
      // effect - persistence
      if (event != null  // exclude initial state
        && oldState != state // trigger only when state changed
      ) {
        print('Simulate persistence save call with state: $state');
      }
    },)
    ...
```


It's not hard to find the first `timer effect` is triggered **on** `increment` event happen,
the second `persistence effect` is triggered by **react** state changes.

Here, We have two kind of **Effect Trigger**:
 *  **Event Based Trigger** 
 *  **State Based Trigger**


### Event Based Trigger

**Event Based Trigger will trigger effect when event meet some condition**.

We have a series of operators (methods) that has prefix `on` to approach this better:


```diff
    ...
-   .add(effect: (state, oldState, event, dispatch) async {
-     // effect - auto decrease via async event
-     if (event is Increment) {
-       await Future<void>.delayed(const Duration(seconds: 3));
-       dispatch(Decrement());
-     }
-   })
+   .on<Increment>(
+     effect: (state, event, dispatch) async {
+       // effect - auto decrease via async event
+       await Future<void>.delayed(const Duration(seconds: 3));
+       dispatch(Decrement());
+     },
+   )
    ...
```

We can even move `effect` around `reduce` when they share same condition:

```diff
    ...
    .on<Increment>(
      reduce: (state, event) => state + 1,
+     effect: (state, event, dispatch) async {
+       // effect - auto decrease via async event
+       await Future<void>.delayed(const Duration(seconds: 3));
+       dispatch(Decrement());
+     },
    )
    .on<Decrement>(
      reduce: (state, event) => state - 1,
    )
    ...
-   .on<Increment>(
-     effect: (state, event, dispatch) async {
-       // effect - auto decrease via async event
-       await Future<void>.delayed(const Duration(seconds: 3));
-       dispatch(Decrement());
-     },
-   )
    ...
```

There are special cases. for example, we want to dispatch events on system run:

```dart
    ...
    .add(effect: (state, oldState, event, dispatch) {
      // mock events
      if (event == null) { // event is null on system run
        dispatch(Increment());
      }
    },);
```

We can use `onRun` operator instead:

```diff
    ...
-   .add(effect: (state, oldState, event, dispatch) {
-     // mock events
-     if (event == null) { // event is null on system run
-       dispatch(Increment());
-     }
-   },);
+   .onRun(effect: (initialState, dispatch) {
+     // mock events
+     dispatch(Increment());
+   },);
```

We have other `on*` operators for different use cases. If we want to learn more please follow the [API Reference]:

* on
* onRun
* onDispose

### State Based Trigger

**State Based Trigger will trigger effect by react to state change.**

We have a series of operators that has prefix `react` to approach this:

```diff
    ...
-   .add(effect: (state, oldState, event, dispatch) {
-     // effect - persistence
-     if (event != null  // exclude initial state
-       && oldState != state // trigger only when state changed
-     ) {
-       print('Simulate persistence save call with state: $state');
-     }
-   },)
+   .react<int>(
+     value: (state) => state,
+     effect: (value, dispatch) {
+       // effect - persistence
+       print('Simulate persistence save call with state: $value');
+     },
+   )
    ...
```

This effect will react to state change then trigger a save call. Since it react to whole state (not partial value) change, we can use a convenience operator `reactState` instead, then we don't need a value map function here:

```diff
-   .react<int>(
-     value: (state) => state,
-     effect: (value, dispatch) {
-       // effect - persistence
-       print('Simulate persistence save call with state: $value');
-     },
-   )
+   .reactState(
+     effect: (state, dispatch) {
+       // effect - persistence
+       print('Simulate persistence save call with state: $state');
+     },
+   )
```

There is another important effect which use this trigger. Can you guess what is it?

Hit: [Flutter] or [React].

Yes, it's `presentation effect`. With declarative UI library like [Flutter] or [React], build (render) is triggered by react to state change. 
We'll discuss this later in **Presentation Effect** Section.

There are other `react*` operators for different use cases. If we want to learn more please follow [API Reference]:

* react
* reactLatest
* reactState

## Run

We've declared our `counterSystem`:

```dart
final counterSystem = System<int, CounterEvent>
  ...;
```

It dose nothing until `run` is called:

```dart
final dispose = counterSystem.run();
```

When `run` is called, a `dispose` function is returned. We can use this `dispose` function to stop system later:

```dart
// stop system after 6 seconds

await Future<void>.delayed(const Duration(seconds: 6)); 

dispose();
```


## Code Review

We've refactored our code a lot to make it better. Let's review it to increase muscle memory.

Old Code:

```dart
final counterSystem = System<int, CounterEvent>
  .create(initialState: 0)
  .add(reduce: (state, event) {
    if (event is Increment) return state + 1;
    return state;
  })
  .add(reduce: (state, event) {
    if (event is Decrement) return state - 1;
    return state;
  })
  .add(effect: (state, oldState, event, dispatch) {
    print('\nEvent: $event');
    print('OldState: $oldState');
    print('State: $state');
  })
  .add(effect: (state, oldState, event, dispatch) async {
    if (event is Increment) {
      await Future<void>.delayed(const Duration(seconds: 3));
      dispatch(Decrement());
    }
  })
  .add(effect: (state, oldState, event, dispatch) {
    if (event != null
      && oldState != state
    ) {
      print('Simulate persistence save call with state: $state');
    }
  },)
  .add(effect: (state, oldState, event, dispatch) {
    if (event == null) { 
      dispatch(Increment());
    }
  });
```

New Code:

```dart
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
  },);
```

## Presentation Effect (With Flutter)

We've mentioned earlier `presentation effect` is triggered by react to state change with declarative UI library:

```dart
  .reactState(
    effect: (state, dispatch) {
      print('Simulate presentation effect (build, render) with state: $state');
    },
  )
```

Since [Flutter] is full of widgets. How can we make `react* operators` work together with widget?

Is this possible:

```dart
  // bellow are just imagination that only works in our mind
  .reactState(
    effect: (state, dispatch) {
      return TextButton(
        onPressed: () => dispatch(Increment()),
        child: Text('$state'),
      );
    },
  )
```

Yeah, we can introduce `React*` widgets, they are combination of `react* operators` and widget:

```dart
Widget build(BuildContext context) {
  return ReactState<int, CounterEvent>(
    system: counterSystem,
    builder: (context, state, dispatch) {
      return TextButton(
        onPressed: () => dispatch(Increment()),
        child: Text('$state'),
      );
    }
  );
}
```

Happy to see [Flutter] and [React] works together ^_-.

If we want to learn more please visit [flutter_love].

## Testing

Test can be done straightforward:

1. create system
2. inject mock events and mock effects
3. record states
4. run the system
5. expect recorded states

```dart
test('CounterSystem', () async {

  final List<State> states = [];

  final counterSystem = System<int, CounterEvent>
    .create(initialState: 0)
    .on<Increment>(
      reduce: (state, event) => state + 1,
    )
    .on<Decrement>(
      reduce: (state, event) => state - 1,
    );

  final dispose = counterSystem.run(
    effect: (state, oldState, event, dispatch) async {
      states.add(state);
      if (event == null) {
        // inject mock events
        dispatch(Increment());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        dispatch(Decrement());
      }
    },
  );

  await Future<void>.delayed(const Duration(milliseconds: 60));

  dispose();

  expect(states, [
    0, // initial state
    1,
    0,
  ]);
  
});

```

## Filter Event Operators

Operators which can prevent unnecessary event dispatching. 

### ignoreEvent

Ignore event based on current state and candidate event.

```dart
  futureSystem
    .ignoreEvent(
      when: (state, event) => event is TriggerLoadData && state.loading
    )
    ...
```

Above code shown if the system is already in loading status, then upcoming `TriggerLoadData` event will be ignored.

### debounceOn

Apply [debounce logic] to some events.

```dart
  searchSystem
    ...
    .on<UpdateKeyword>(
      reduce: (state, event) => state.copyWith(keyword: event.keyword)
    )
    .debounceOn<UpdateKeyword>(
      duration: const Duration(seconds: 1)
    )
    ...
```

Above code shown if `UpdateKeyword` event is dispatched with high frequency (quick typing), system will drop these events to reduce unnecessary dispatching, it will pass event if dispatched event is stable.

  
## Credits

Without community this library won't be born. So, thank [ReactiveX] community, [Redux] community and [RxSwift] community. 

Thank [@miyoyo] for giving feedback that helped us shape this library.

Special thank to [@kzaher] who is original author of [RxSwift] and [RxFeedback], he shared a lot of knowledge with us, that make this library possible today.

Last and important, thank you for reading!
## License

The MIT License (MIT)

## End is Start

![][love_overview_diagram]


[love_overview_diagram]:https://raw.githubusercontent.com/LoveCommunity/love.dart/cae498b8648b677b7f45865ea15c69221e2b747e/docs/assets/images/love_overview_diagram.png
[love_detail_diagram]:https://raw.githubusercontent.com/LoveCommunity/love.dart/cae498b8648b677b7f45865ea15c69221e2b747e/docs/assets/images/love_detail_diagram.png

[love]:https://pub.dev/packages/love/versions/0.1.0-beta.6
[install love]:https://pub.dev/packages/love/versions/0.1.0-beta.6/install
[flutter_love]:https://pub.dev/packages/flutter_love/versions/0.1.0-beta.6
[install flutter_love]:https://pub.dev/packages/flutter_love/versions/0.1.0-beta.6/install
[ReactiveX]:http://reactivex.io/
[debounce logic]:http://reactivex.io/documentation/operators/debounce.html
[Redux]:https://redux.js.org/
[RxFeedback]:https://github.com/NoTests/RxFeedback.swift
[RxSwift]:https://github.com/ReactiveX/RxSwift
[Flutter]:https://flutter.dev/
[React]:https://reactjs.org/
[API Reference]:https://pub.dev/documentation/love/0.1.0-beta.6/love/love-library.html
[@kzaher]:https://github.com/kzaher
[@miyoyo]:https://github.com/miyoyo