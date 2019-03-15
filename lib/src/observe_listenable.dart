import 'package:flutter/widgets.dart';

import 'active_observers.dart';
import 'observe_effect.dart';

/// Add a listener to a [Listenable]. The listener will be automatically cancelled
/// when the [State] is disposed.
ActiveObserver<void> observeListenable(
    Listenable getListenable(), VoidCallback callback) {
  return (ActiveObservers host) {
    Listenable listenable;
    observeEffect(() {
      listenable = getListenable();
      listenable.addListener(callback);
      return () {
        listenable.removeListener(callback);
      };
    }, () => listenable == getListenable())(host);
  };
}
