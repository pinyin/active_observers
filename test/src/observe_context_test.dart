import 'package:active_observers/active_observers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('observeContext', () {
    testWidgets('should support default value', (tester) async {
      await tester.pumpWidget(TestObserveContext());
      expect(find.text('default'), findsOneWidget);
    });
    testWidgets('should update value with widget', (tester) async {
      await tester
          .pumpWidget(InheritedWidgetExample('a', TestObserveContext()));
      expect(find.text('a'), findsOneWidget);
      await tester
          .pumpWidget(InheritedWidgetExample('b', TestObserveContext()));
      expect(find.text('b'), findsOneWidget);
    });
    testWidgets('should emit value iff widget is updated', (tester) async {
      var updateCount = 0;
      await tester.pumpWidget(TestObserveContext(onValue: () => updateCount++));
      expect(updateCount, 0);
      await tester.pumpWidget(InheritedWidgetExample(
          'a', TestObserveContext(onValue: () => updateCount++)));
      expect(updateCount, 0);
      await tester.pumpWidget(InheritedWidgetExample(
          'b', TestObserveContext(onValue: () => updateCount++)));
      expect(updateCount, 1);
      final widget = InheritedWidgetExample(
          'a', TestObserveContext(onValue: () => updateCount++),
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

  static of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(InheritedWidgetExample) ??
        defaultDeps;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}

class TestObserveContext extends StatefulWidget {
  final Function() onValue;

  const TestObserveContext({Key key, this.onValue}) : super(key: key);

  @override
  _TestObserveContextState createState() => _TestObserveContextState();
}

class _TestObserveContextState extends State<TestObserveContext>
    with ActiveObservers {
  @override
  void assembleActiveObservers() {
    final inherited = observeContext(InheritedWidgetExample.of);
    value = inherited.value.value;
    observeListenable(() => inherited, () {
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
