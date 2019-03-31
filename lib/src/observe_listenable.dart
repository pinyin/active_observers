import 'package:flutter/widgets.dart';

import 'observe_effect.dart';

/// Add a listener to a [Listenable]. The listener will be automatically removed
/// when the [State] is disposed.
void observeListenable(Listenable getListenable(), VoidCallback callback) {
  Listenable listenable;
  observeEffect(() {
    listenable = getListenable();
    listenable.addListener(callback);
    return () {
      listenable.removeListener(callback);
    };
  }, restartWhen: () => listenable != getListenable());
}
