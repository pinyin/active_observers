import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

bool alwaysReturnTrue() {
  return true;
}

abstract class Memo<T> implements ValueListenable<T>, Future<T> {
  T call();
}

// TODO how to test this?
class MemoController<T> extends ValueNotifier<T> implements Memo<T> {
  MemoController(T value) : super(value);

  call() => this.value;

  @override
  Stream<T> asStream() {
    final result = StreamController<T>();

    void forward() {
      result.add(value);
    }

    result.onListen = () {
      addListener(forward);
    };
    result.onCancel = () {
      removeListener(forward);
      return result.close();
    };
    result.add(value);

    return result.stream;
  }

  @override
  Future<T> catchError(Function onError, {bool Function(Object error) test}) {
    return null;
  }

  @override
  Future<R> then<R>(FutureOr<R> Function(T value) onValue,
      {Function onError}) async {
    final result = Completer<T>();
    void forward() {
      result.complete(value);
      removeListener(forward);
    }

    addListener(forward);

    return onValue(await result.future);
  }

  @override
  Future<T> timeout(Duration timeLimit,
      {FutureOr<T> Function() onTimeout}) async {
    final result = Completer<T>();
    void forward() {
      result.complete(value);
      removeListener(forward);
    }

    addListener(forward); // FIXME release listener on timeout

    return result.future.timeout(timeLimit, onTimeout: onTimeout);
  }

  @override
  Future<T> whenComplete(FutureOr Function() action) {
    final result = Completer<T>();
    void forward() {
      result.complete(value);
      removeListener(forward);
    }

    addListener(forward);

    return result.future.whenComplete(action);
  }
}

class Ref<T> {
  T value;

  Ref(this.value);
}
