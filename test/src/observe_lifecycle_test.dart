import 'package:active_observers/active_observers.dart';
import 'package:active_observers/src/observe_lifecycle.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('observeEffect', () {
    testWidgets('should call callbacks on specified lifecycle phases',
        (tester) async {
      List<StateLifecyclePhase> report = [];
      await tester.pumpWidget(TestObserveLifecycle(report.add));
      expect(report, [StateLifecyclePhase.didChangeDependencies]);
      report.clear();
      await tester.pumpWidget(TestObserveLifecycle((v) => report.add(v)));
      expect(report, [StateLifecyclePhase.didUpdateWidget]);
      report.clear();
      await tester.pumpWidget(Container());
      expect(report,
          [StateLifecyclePhase.deactivate, StateLifecyclePhase.dispose]);
      report.clear();
    });
  });
}

class TestObserveLifecycle extends StatefulWidget {
  TestObserveLifecycle(this.report);

  final void Function(StateLifecyclePhase) report;

  @override
  _TestObserveLifecycleState createState() => _TestObserveLifecycleState();
}

class _TestObserveLifecycleState extends State<TestObserveLifecycle>
    with ActiveObservers {
  @override
  assembleActiveObservers() {
    observeLifecycle((phase) => widget.report(phase));
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
