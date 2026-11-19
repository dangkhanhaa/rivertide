import 'package:flutter/material.dart';

/// Tab container (P2-42): keeps every tab alive like an IndexedStack, but
/// fades the newly selected tab in instead of cutting to it. Hidden tabs get
/// no ticks, so their animations cost nothing.
class FadeBranches extends StatefulWidget {
  const FadeBranches({required this.index, required this.children, super.key});

  final int index;
  final List<Widget> children;

  @override
  State<FadeBranches> createState() => _FadeBranchesState();
}

class _FadeBranchesState extends State<FadeBranches> with SingleTickerProviderStateMixin {
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
    value: 1,
  );
  late final Animation<double> _curve = CurvedAnimation(parent: _fade, curve: Curves.easeOut);

  @override
  void didUpdateWidget(FadeBranches old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index && !MediaQuery.disableAnimationsOf(context)) {
      _fade.forward(from: 0.35);
    }
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _curve,
    child: IndexedStack(
      index: widget.index,
      children: [
        for (final (i, child) in widget.children.indexed)
          TickerMode(enabled: i == widget.index, child: child),
      ],
    ),
  );
}
