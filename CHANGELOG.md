## [0.0.1]

* initial release

## [0.1.0]

* Add `ActiveObserver` interface

## [0.1.1]

* Add `observeStream` 

## [0.1.2]

* Add `observeListenable` & `observeValueListenableState`

## [0.2.0]

* Add dependency update detection logic

## [0.3.0]

* Major rewrite
* Remove dependencies other than Flutter
* Active observers should be called in State's constructor

## [0.3.1]

* Make active observers run in the expected order

## [0.3.2]

* Always restart effect on `reassemble`

## [0.3.3]

* Add `assembleActiveObservers` slot

## [0.3.4]

* Clean active observers on reassemble
* Now all active observers must be placed in `assembleActiveObservers`

## [0.4.0]

* Use implicit this in active observers

## [0.4.1]

* Mark `assembleActiveObservers` as virtual

## [0.5.0]

* Update `observeLifecycle` interface

## [0.5.1]

* Add example

## [0.6.0]

* Add `didSetState` lifecycle
* `observeEffect` now receive a function to decide when to restart
* `observeEffect` now may restart effect in setState
* Add `observePaint` observer

## [0.7.0]

* Add `observeContext` and `observeInheritedWidget`
* Adjust reassemble order 
* Remove second parameter of `observeStream`  & `observeListenable`, use return value instead
* Add additional lifecycle methods
* Update multiple interface
* Improve calling performance