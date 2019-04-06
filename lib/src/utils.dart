import 'package:flutter/foundation.dart';

bool alwaysReturnTrue() {
  return true;
}

abstract class Memo<T> implements ValueListenable<T> {
  T call();
}

class MemoImpl<T> extends ValueNotifier<T> implements Memo<T> {
  MemoImpl(T value) : super(value);

  call() => this.value;
}
