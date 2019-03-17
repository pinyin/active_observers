import 'observe_effect.dart';

/// Add a listener to a stream. The listener will be automatically cancelled
/// when the [State] is disposed.
void observeStream<T>(Stream<T> getStream(), void onData(T event),
    {void Function(Object, StackTrace) onError, void onDone()}) {
  Stream<T> stream;
  return observeEffect(() {
    stream = getStream();
    return getStream().listen(onData, onError: onError, onDone: onDone).cancel;
  }, () => stream == getStream());
}
