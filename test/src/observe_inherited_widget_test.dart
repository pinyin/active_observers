import 'package:active_observers/active_observers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('observeInheritedWidget', () {
    testWidgets('should support default value', (tester) async {
      await tester.pumpWidget(TestObserverInheritedWidget());
      expect(find.text('default'), findsOneWidget);
    });
    testWidgets('should update value with widget', (tester) async {
      await tester.pumpWidget(
          InheritedWidgetExample('a', TestObserverInheritedWidget()));
      expect(find.text('a'), findsOneWidget);
      await tester.pumpWidget(
          InheritedWidgetExample('b', TestObserverInheritedWidget()));
      expect(find.text('b'), findsOneWidget);
    });
    testWidgets('should emit value iff widget is updated', (tester) async {
      var updateCount = 0;
      await tester.pumpWidget(
          TestObserverInheritedWidget(onValue: () => updateCount++));
      expect(updateCount, 0);
      await tester.pumpWidget(InheritedWidgetExample(
          'a', TestObserverInheritedWidget(onValue: () => updateCount++)));
      expect(updateCount, 0);
      await tester.pumpWidget(InheritedWidgetExample(
          'b', TestObserverInheritedWidget(onValue: () => updateCount++)));
      expect(updateCount, 1);
      final widget = InheritedWidgetExample(
          'a', TestObserverInheritedWidget(onValue: () => updateCount++),
          key: GlobalKey());
      await tester.pumpWidget(widget);
      expect(updateCount, 1);
      await tester.pumpWidget(InheritedWidgetExample('b', widget));
      expect(updateCount, 1);
      await tester.pumpWidget(widget);
      expect(updateCount, 1);
    });
  });
}

class InheritedWidgetExample extends InheritedWidget {
  final String value;
  final Widget child;

  InheritedWidgetExample(this.value, this.child, {Key key})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}

class TestObserverInheritedWidget extends StatefulWidget
    with DetailedLifecycleInState {
  final Function() onValue;

  const TestObserverInheritedWidget({Key key, this.onValue}) : super(key: key);

  @override
  _TestObserverInheritedWidgetState createState() =>
      _TestObserverInheritedWidgetState();
}

class _TestObserverInheritedWidgetState
    extends State<TestObserverInheritedWidget> with ActiveObservers {
  @override
  void assembleActiveObservers() {
    final inherited = observeInheritedWidget(() => defaultDeps);
    value = inherited.value.value;
    inherited.addListener(() {
      if (widget.onValue != null) widget.onValue();
      value = inherited.value.value;
    });
  }

  String value;

  @override
  Widget build(BuildContext context) {
    return Text(value, textDirection: TextDirection.ltr);
  }
}

final defaultDeps = InheritedWidgetExample('default', Container());
