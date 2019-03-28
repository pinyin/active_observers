import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

Observable<T> listen$<L extends Listenable, T>(L listenable, T getValue()) {
  final subject = PublishSubject<T>();

  void emit() {
    final value = getValue();
    if (value == null) return;
    subject.add(value);
  }

  subject.onListen = () => listenable.addListener(emit);
  subject.onCancel = () => listenable.removeListener(emit);

  return subject.share();
}
