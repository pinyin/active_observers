import 'active_observers.dart';
import 'observe_effect.dart';

/// Add a listener to a stream. The listener will be automatically cancelled
/// when the [State] is disposed.
ActiveObserver<void> observeStream<T>(
    Stream<T> getStream(), void onData(T event),
    {void Function(Object, StackTrace) onError, void onDone()}) {
  return (host) {
    Stream<T> stream;
    return observeEffect(() {
      stream = getStream();
      return getStream()
          .listen(onData, onError: onError, onDone: onDone)
          .cancel;
    }, () => stream == getStream())(host);
  };
}
