import 'package:active_observers/active_observers.dart';
import 'package:active_observers/src/active_observers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ActiveObservers', () {
    testWidgets('should call observers in expected order', (tester) async {
      final reports = <Report>[];
      await tester.pumpWidget(TestObserveOrder(report: reports.add));
      expect(reports.map((r) => r.order), [1, 2, 1, 2]);
      expect(reports.map((r) => r.phase), [
        StateLifecyclePhase.didChangeDependencies,
        StateLifecyclePhase.didChangeDependencies,
      ]);
      reports.clear();
      await tester.pumpWidget(TestObserveOrder(report: reports.add));
      expect(reports.map((r) => r.order), [1, 2]);
      expect(reports.map((r) => r.phase), [
        StateLifecyclePhase.didUpdateWidget,
        StateLifecyclePhase.didUpdateWidget,
      ]);
      reports.clear();
      await tester.pumpWidget(Container());
      expect(reports.map((r) => r.order), [2, 1, 2, 1]);
      expect(reports.map((r) => r.phase), [
        StateLifecyclePhase.deactivate,
        StateLifecyclePhase.deactivate,
        StateLifecyclePhase.dispose,
        StateLifecyclePhase.dispose,
      ]);
    });
  });
}

@immutable
class Report {
  final int order;
  final StateLifecyclePhase phase;

  Report(this.order, this.phase);
}

class TestObserveOrder extends StatefulWidget {
  final void Function(Report) report;

  const TestObserveOrder({Key key, this.report}) : super(key: key);

  @override
  _TestObserveOrderState createState() => _TestObserveOrderState();
}

class _TestObserveOrderState extends State<TestObserveOrder>
    with ActiveObservers {
  // TODO find a way to test reassemble

  @override
  assembleActiveObservers() {
    activeObservers.add((phase) {
      widget.report(Report(1, phase));
    });
    activeObservers.add((phase) {
      widget.report(Report(2, phase));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
