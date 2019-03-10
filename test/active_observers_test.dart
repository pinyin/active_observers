import 'dart:async';

import 'package:active_observers/active_observers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:observable_state_lifecycle/observable_state_lifecycle.dart';

void main() {
  group('observeState', () {
    testWidgets('should update widget with value', (tester) async {
      ObserveState<String> state;
      await tester.pumpWidget(TestObserveState((s) {
        state = s;
      }));
      expect(state.value, 'a');
      expect(find.text('a'), findsOneWidget);
      state.value = 'b';
      await tester.pump();
      expect(state.value, 'b');
      expect(find.text('b'), findsOneWidget);
    });
  });

  group('observeEffect', () {
    testWidgets('should run between initState & dispose', (tester) async {
      List<StateLifecyclePhase> report = [];
      await tester.pumpWidget(TestObserveEffect((phase) {
        report.add(phase);
      }));
      expect(report,
          [StateLifecyclePhase.initState, StateLifecyclePhase.didUpdateWidget]);
      report.clear();
      await tester.pumpWidget(TestObserveEffect((phase) {
        report.add(phase);
      }));
      expect(report, [StateLifecyclePhase.didUpdateWidget]);
      report.clear();
      await tester.pumpWidget(TestObserveEffect((phase) {
        report.add(phase);
      }, false));
      expect(report, [
        StateLifecyclePhase.dispose, // previous effect terminated
        StateLifecyclePhase.didUpdateWidget,
        StateLifecyclePhase.didUpdateWidget
      ]);
      await tester.pumpWidget(Container());
      report.clear();
      await tester.pumpWidget(TestObserveEffect((phase) {
        report.add(phase);
      }));
      await tester.pumpWidget(Container());
      expect(report, [
        StateLifecyclePhase.initState,
        StateLifecyclePhase.didUpdateWidget,
        StateLifecyclePhase.dispose,
        StateLifecyclePhase.dispose
      ]);
    });
  });

  group('observeStream', () {
    testWidgets('should call onData when value comes', (tester) async {
      final subject = StreamController<String>(sync: true);
      await tester.pumpWidget(TestObserveStream(stream: subject.stream));
      subject.add('1');
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
      subject.add('2');
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
      subject.close();
    });
    testWidgets('should call onError after error happened', (tester) async {
      final subject = StreamController<String>(sync: true);
      await tester.pumpWidget(TestObserveStream(stream: subject.stream));
      subject.addError('1');
      await tester.pump();
      expect(find.text('error'), findsOneWidget);
      subject.close();
    });
    testWidgets('should call onDone after stream closed', (tester) async {
      final subject = StreamController<String>(sync: true);
      await tester.pumpWidget(TestObserveStream(stream: subject.stream));
      subject.close();
      await tester.pump();
      expect(find.text('done'), findsOneWidget);
      subject.close();
    });
  });

  group('observeListenable', () {
    testWidgets('should subscribe to Listenable', (tester) async {
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
    testWidgets('should automatically unsubscribe from Listenable',
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
  });

  group('observeValueListener', () {
    testWidgets('should update widget with value', (tester) async {
      final source = ValueNotifier('a');
      await tester.pumpWidget(TestObserveValueListenable(listenable: source));
      expect(find.text('a'), findsOneWidget);
      source.value = 'b';
      await tester.pump();
      expect(find.text('b'), findsOneWidget);
    });
    testWidgets('should automatically unsubscribe from ValueListenable',
        (tester) async {
      final source = ValueNotifier('a');
      await tester.pumpWidget(TestObserveValueListenable(listenable: source));
      expect(find.text('a'), findsOneWidget);
      expect(source.hasListeners, true);
      await tester.pumpWidget(Container());
      source.value = 'b';
      expect(source.hasListeners, false);
    });
  });
}

class TestObserveValueListenable extends StatefulWidget {
  final ValueListenable<String> listenable;

  const TestObserveValueListenable({Key key, this.listenable})
      : super(key: key);

  @override
  _TestObserveValueListenableState createState() =>
      _TestObserveValueListenableState();
}

class _TestObserveValueListenableState extends State<TestObserveValueListenable>
    with ObservableStateLifecycle<TestObserveValueListenable> {
  @override
  void initState() {
    super.initState();
    value = observeState(widget.listenable.value)(this);
    observeValueListenable(widget.listenable, value.set)(this);
  }

  ObserveState<String> value;

  @override
  Widget build(BuildContext context) {
    return Text(value.value, textDirection: TextDirection.ltr);
  }
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
    with ObservableStateLifecycle<TestObserveListenable> {
  @override
  void initState() {
    super.initState();
    observeListenable(widget.listenable, widget.report)(this);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class TestObserveState extends StatefulWidget {
  TestObserveState(this.reportState);

  final void Function(ObserveState<String>) reportState;

  @override
  _TestObserveStateState createState() => _TestObserveStateState();
}

class _TestObserveStateState extends State<TestObserveState>
    with ObservableStateLifecycle<TestObserveState> {
  @override
  initState() {
    super.initState();
    state = observeState('a')(this);
  }

  ObserveState<String> state;

  @override
  Widget build(BuildContext context) {
    widget.reportState(state);
    return Text(state.value, textDirection: TextDirection.ltr);
  }
}

class TestObserveEffect extends StatefulWidget {
  TestObserveEffect(this.reportState, [this.isIdentical = true]);

  final bool isIdentical;
  final void Function(StateLifecyclePhase) reportState;

  @override
  _TestObserveEffectState createState() => _TestObserveEffectState();
}

class _TestObserveEffectState extends State<TestObserveEffect>
    with ObservableStateLifecycle<TestObserveEffect> {
  @override
  initState() {
    super.initState();
    widget.reportState(StateLifecyclePhase.initState);
    observeEffect(() {
      widget.reportState(StateLifecyclePhase.didUpdateWidget);
      return () => {widget.reportState(StateLifecyclePhase.dispose)};
    }, () => widget.isIdentical)(this);
  }

  @override
  void didUpdateWidget(TestObserveEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.reportState(StateLifecyclePhase.didUpdateWidget);
  }

  @override
  void dispose() {
    widget.reportState(StateLifecyclePhase.dispose);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class TestObserveStream extends StatefulWidget {
  const TestObserveStream({Key key, this.stream}) : super(key: key);

  final Stream<String> stream;

  @override
  _TestObserveStreamState createState() => _TestObserveStreamState();
}

class _TestObserveStreamState extends State<TestObserveStream>
    with ObservableStateLifecycle<TestObserveStream> {
  @override
  void initState() {
    super.initState();
    observeStream(widget.stream, (value) {
      setState(() {
        state = value;
      });
    }, onDone: () {
      setState(() {
        state = 'done';
      });
    }, onError: (_, __) {
      setState(() {
        state = 'error';
      });
    })(this);
  }

  String state = '';

  @override
  Widget build(BuildContext context) {
    return Text(state, textDirection: TextDirection.ltr);
  }
}
