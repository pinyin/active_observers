import 'dart:async';

import 'package:active_observers/active_observers.dart';

/// Create a proxy to a stream. The subscriptions will be automatically cancelled
/// when host [State] is disposed.
Stream<T> observeStream<T>(Stream<T> getStream()) {
  final controller = StreamController<T>();

  Stream<T> stream;
  observeEffect(() {
    stream = getStream();
    // TODO handle resubscribe on error?
    return stream.listen(controller.add, onError: controller.addError).cancel;
  }, restartWhen: () => stream != getStream());

  observeDispose(controller.close);

  return controller.stream;
}
