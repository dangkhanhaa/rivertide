import 'package:flutter/widgets.dart';

/// Lets a detail view close whatever hosts it (bottom sheet or side panel)
/// before navigating away, without knowing which one it is in.
class DetailHost extends InheritedWidget {
  const DetailHost({required this.close, required super.child, super.key});

  final VoidCallback close;

  static void closeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<DetailHost>()?.close();

  @override
  bool updateShouldNotify(DetailHost oldWidget) => false;
}
