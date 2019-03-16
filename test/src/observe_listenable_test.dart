import 'package:active_observers/active_observers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('observeListenable', () {
    testWidgets('should subscribe to Listenable on first build',
        (tester) async {
      int count = 0;
      final source = ValueNotifier(0);
      final Listenable listenable = source;
      await tester.pumpWidget(
          TestObserveListenable(listenable: listenable, report: () => count++));
      expect(count, 0);
      source.value = 1;
      await tester.pump();
      expect(count, 1);
      await tester.pumpWidget(
          TestObserveListenable(listenable: listenable, report: () => count++));
      await tester.pump();
      expect(count, 1);
    });
    testWidgets('should automatically unsubscribe from Listenable on dispose',
        (tester) async {
      int count = 0;
      final source = ValueNotifier(0);
      final Listenable listenable = source;
      await tester.pumpWidget(
          TestObserveListenable(listenable: listenable, report: () => count++));
      expect(source.hasListeners, true); // FIXME calling protected method
      expect(count, 0);
      await tester.pumpWidget(Container());
      source.value = 1;
      expect(count, 0);
      expect(source.hasListeners, false);
    });
    testWidgets('should resubscribe on widget update if necessary',
        (tester) async {
      int count = 0;
      final source = ValueNotifier(0);
      final Listenable listenable = source;
      await tester.pumpWidget(
          TestObserveListenable(listenable: listenable, report: () => count++));
      expect(count, 0);
      source.value = 1;
      final source2 = ValueNotifier(0);
      final Listenable listenable2 = source2;
      await tester.pumpWidget(TestObserveListenable(
          listenable: listenable2, report: () => count++));
      expect(count, 1);
      expect(source.hasListeners, false);
      expect(source2.hasListeners, true);
    });
  });
}

class TestObserveListenable extends StatefulWidget {
  final Listenable listenable;
  final VoidCallback report;

  const TestObserveListenable({Key key, this.listenable, this.report})
      : super(key: key);

  @override
  _TestObserveListenableState createState() => _TestObserveListenableState();
}

class _TestObserveListenableState extends State<TestObserveListenable>
    with ActiveObservers {
  assembleActiveObservers() {
    observeListenable(() => widget.listenable, () => widget.report())(this);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
