## main

* refactor - rename `areEqual` to `equals` to be consistent with dart [#93](https://github.com/LoveCommunity/love.dart/issues/93)
* refactor - rename `EventInterceptor` to `InterceptorWithContext`

## [0.1.0-beta.6] - 2020-09-22

* refactor - rename parameter `skipFirst*` to `skipInitial*`
* refactor - reimplement `system.react` and `system.reactLatest` operators
* feature - add `system.log` operator
* feature - add `system.eventInterceptor` operator to intercept event
* feature - add `system.ignoreEvent` operator to filter event
* feature - add `system.debounceOn` operator

## [0.1.0-beta.5] - 2020-08-06

* refactor - remove `system.onLatest` operator for simplicity
* refactor - remove `system.reactRequest` operator for simplicity
* refactor - remove `system.reactLatestRequest` operator for simplicity
* feature - add `system.reactState` operator
* refactor - change operator `system.react*` parameter `skipFirst*` default to true

## [0.1.0-beta.4] - 2020-07-12

* refactor - downgrade meta to version 1.3.0 to compatible with flutter test

## [0.1.0-beta.3] - 2020-07-12

* refactor - remove `EffectSystem` for simplicity
* refactor - update `system.share*` operators to return `System` 
* refactor - make `EffectForwarder` internal
* refactor - remove types `EffectSystemRun` and `CopyEffectSystemRun`

## [0.1.0-beta.2] - 2020-07-05

* refactor - remove `onEvent` and `reactState` operators
* docs - add `Libraries` section

## [0.1.0-beta.1] - 2020-06-18

* feature - add `System<State, Event>` and operators
* feature - add `EffectSystem<State, Event>` and operators
* feature - add `EffectForwarder<State, Event>`
* feature - add type `AreEqual<T>`
* feature - add type `Reduce<State, Event>`
* feature - add type `Dispatch<Event>`
* feature - add type `Effect<State, Event>`
* feature - add type `Dispose`
* feature - add type `Run<State, Event>`
* feature - add type `EffectSystemRun<State, Event>`
* feature - add type `Moment<State, Event> `
