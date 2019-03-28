import 'package:active_observers/active_observers.dart';
import 'package:flutter/material.dart';

class Item extends StatefulWidget {
  const Item({
    @required this.item,
    Key key,
    this.onNeedFullView,
  }) : super(key: key);

  final void Function(bool) onNeedFullView;
  final int item;

  @override
  _ItemState createState() => _ItemState();
}

class _ItemState extends State<Item> with ActiveObservers {
  @override
  void assembleActiveObservers() {
    if (widget.onNeedFullView != null) widget.onNeedFullView(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Hero(
              tag: '${widget.item}',
              child: Text('content ${widget.item}'),
            ),
          ),
        ],
      ),
    );
  }
}

@immutable
class ItemArguments {
  final int item;

  ItemArguments(this.item);
}
