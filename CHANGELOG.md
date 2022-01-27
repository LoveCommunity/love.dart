## [0.1.2] - 2022-01-27

* docs - prefer `https` over `http` with ReactiveX docs link in [137](https://github.com/LoveCommunity/love.dart/pull/137)
* refactor - extract `Equals<T>` to another library in [139](https://github.com/LoveCommunity/love.dart/pull/139)

## [0.1.1] - 2020-12-08

* docs - add shields images by @beeth0ven in [133](https://github.com/LoveCommunity/love.dart/pull/133)
* tests - add all tests `love_test.dart` by @beeth0ven in [132](https://github.com/LoveCommunity/love.dart/pull/132)
* feature - add code coverage report to CI by @beeth0ven in [131](https://github.com/LoveCommunity/love.dart/pull/131)
* CI - only trigger CI tests on push and pull request with main branch by @beeth0ven in [134](https://github.com/LoveCommunity/love.dart/pull/134)
  
## [0.1.0] - 2020-11-19

* docs - improve API documentation for `system.dart` by @beeth0ven in https://github.com/LoveCommunity/love.dart/pull/123
* docs - improve API documentation for `systems/on_x.dart` by @beeth0ven in https://github.com/LoveCommunity/love.dart/pull/125
* docs - improve API documentation for `systems/react_x.dart` by @beeth0ven in https://github.com/LoveCommunity/love.dart/pull/127

## [0.1.0-rc.3] - 2020-11-05

* refactor - explicit import and export types [#112](https://github.com/LoveCommunity/love.dart/issues/112)
* refactor - remove unused internal type `CopySystem` [#113](https://github.com/LoveCommunity/love.dart/issues/113)
* refactor - extract `moment` class [#114](https://github.com/LoveCommunity/love.dart/issues/114)
* refactor - extract `safeAs` function [#115](https://github.com/LoveCommunity/love.dart/issues/115)
* refactor - extract `combine` functions [#116](https://github.com/LoveCommunity/love.dart/issues/116)
* refactor - extract `defaultEquals` function [#117](https://github.com/LoveCommunity/love.dart/issues/117)
* break - refactor - remove `DispatchFunc` type [#118](https://github.com/LoveCommunity/love.dart/issues/118)

## [0.1.0-rc.2] - 2020-10-28

* break - refactor - rename `Dispose` to `Disposer` [#107](https://github.com/LoveCommunity/love.dart/issues/107)
* break - refactor - rename extension names to have a `x` suffix [#109](https://github.com/LoveCommunity/love.dart/issues/109)

## [0.1.0-rc.1] - 2020-10-19

* refactor - rename `areEqual` to `equals` to be consistent with dart [#93](https://github.com/LoveCommunity/love.dart/issues/93)
* refactor - rename `EventInterceptor` to `InterceptorWithContext` [#96](https://github.com/LoveCommunity/love.dart/issues/96)
* refactor - add `interceptor` to system [#96](https://github.com/LoveCommunity/love.dart/issues/96)
* refactor - reimplement `eventInterceptor` for composability [#96](https://github.com/LoveCommunity/love.dart/issues/96)
* refactor - expose `system.runWithContext`'s `dispose` callback for disposing context [#98](https://github.com/LoveCommunity/love.dart/issues/98)
* refactor - add `effectForwarder.dispose` method [#99](https://github.com/LoveCommunity/love.dart/issues/99)
* refactor - prefer using `Object` as version identifier in `LatestContext` [#100](https://github.com/LoveCommunity/love.dart/issues/100)
* example - refactor - renames `CounterEventIncrease` to `Increment`, `CounterEventDecrease` to `Decrement` [#101](https://github.com/LoveCommunity/love.dart/issues/101)

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
