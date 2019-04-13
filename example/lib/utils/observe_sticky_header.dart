import 'dart:async';

import 'package:active_observers/active_observers.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

AnimationController observeStickyHeader(
  Iterable<Stream<ScrollPosition>> scrollers,
  TickerProvider vsync,
) {
  final controller = AnimationController(
      duration: Duration(milliseconds: 300), value: 1, vsync: vsync);

  Stream<double> diffScroll(Stream<ScrollPosition> scrollPosition$) async* {
    double prevOffset;

    await for (final position in scrollPosition$) {
      final offset = position.pixels;
      if (prevOffset != null) yield offset - prevOffset;
      prevOffset = offset;
    }
  }

  final Observable<double> scrollDiff$ = Observable.merge(scrollers
      .map((p$) => p$.transform(StreamTransformer.fromBind(diffScroll))));

  observeStream(() => scrollDiff$).listen((double diff) {
    controller.value = controller.value - diff / kToolbarHeight;
  });

  return controller;
}
