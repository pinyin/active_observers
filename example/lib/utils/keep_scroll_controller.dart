import 'package:flutter/widgets.dart';

class KeepScrollController extends TrackingScrollController {
  KeepScrollController({
    double initialScrollOffset = 0.0,
    bool keepScrollOffset = true,
    String debugLabel,
  })  : initialScrollOffset = initialScrollOffset,
        super(
            initialScrollOffset: initialScrollOffset,
            keepScrollOffset: keepScrollOffset,
            debugLabel: debugLabel);

  @override
  double initialScrollOffset;

  ScrollPosition get mostRecentlyUpdatedPosition {
    initialScrollOffset = super.mostRecentlyUpdatedPosition?.pixels ?? 0;
    return super.mostRecentlyUpdatedPosition;
  }
}
