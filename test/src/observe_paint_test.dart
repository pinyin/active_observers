import 'package:active_observers/active_observers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('observePaint', () {
    testWidgets('should run after initState', (tester) async {
      List<Report> report = [];
      await tester.pumpWidget(TestObservePaint((phase) {
        report.add(phase);
      }));
      expect(report, [Report.InitState, Report.PaintStart]);
      report.clear();
    });

    testWidgets('should rerun iff rerunWhen() returns true after update',
        (tester) async {
      List<Report> report = [];
      await tester.pumpWidget(TestObservePaint((phase) {
        report.add(phase);
      }));
      report.clear();
      await tester.pumpWidget(TestObservePaint((phase) {
        report.add(phase);
      }, true));
      expect(report, [Report.DidUpdateState]);
      report.clear();
      await tester.pumpWidget(TestObservePaint((phase) {
        report.add(phase);
      }, false));
      expect(report, [Report.DidUpdateState, Report.PaintStart]);
      report.clear();
    });
  });
}

enum Report { InitState, PaintStart, DidUpdateState }

class TestObservePaint extends StatefulWidget with DetailedLifecycleInState {
  TestObservePaint(this.report, [this.isIdentical = true]);

  final bool isIdentical;
  final void Function(Report) report;

  @override
  _TestObservePaintState createState() => _TestObservePaintState();
}

class _TestObservePaintState extends State<TestObservePaint>
    with ActiveObservers {
  @override
  assembleActiveObservers() {
    observePaint(() {
      widget.report(Report.PaintStart);
    }, rerunWhen: () => !widget.isIdentical);
  }

  @override
  void initState() {
    super.initState();
    widget.report(Report.InitState);
  }

  @override
  void didUpdateWidget(TestObservePaint oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.report(Report.DidUpdateState);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
