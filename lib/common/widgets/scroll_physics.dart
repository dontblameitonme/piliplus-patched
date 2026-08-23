import 'package:PiliPlus/common/widgets/flutter/page/tabs.dart';
import 'package:PiliPlus/common/widgets/gesture/horizontal_drag_gesture_recognizer.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart' hide TabBarView;

/// A wrapper that defers inflation of [child] until the first time this
/// widget is activated (becomes visible in its TabBarView). Once inflated the
/// child is kept alive so subsequent tab switches are instant.
class LazyIndexedTab extends StatefulWidget {
  const LazyIndexedTab({super.key, required this.child});
  final Widget child;

  @override
  State<LazyIndexedTab> createState() => _LazyIndexedTabState();
}

class _LazyIndexedTabState extends State<LazyIndexedTab>
    with AutomaticKeepAliveClientMixin {
  bool _initialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void activate() {
    super.activate();
    // Called when this subtree is reinserted into the tree after being removed
    // via deactivate (e.g., tab switches in TabBarView). We also use it as the
    // first-time initialization trigger.
    if (!_initialized) {
      setState(() => _initialized = true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Also initialize when first mounted and the ticker is enabled.
    if (!_initialized && TickerMode.valuesOf(context).enabled) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_initialized) {
      return const SizedBox.shrink();
    }
    return widget.child;
  }
}

Widget tabBarView({
  required List<Widget> children,
  TabController? controller,
}) =>
    TabBarView<CustomHorizontalDragGestureRecognizer>(
      controller: controller,
      physics: clampingScrollPhysics,
      dragStartBehavior: DragStartBehavior.down,
      horizontalDragGestureRecognizer: CustomHorizontalDragGestureRecognizer.new,
      children: children
          .map((child) => RepaintBoundary(child: child))
          .toList(growable: false),
    );

SpringDescription _customSpringDescription() {
  final List<double> springDescription = Pref.springDescription;
  return SpringDescription(
    mass: springDescription[0],
    stiffness: springDescription[1],
    damping: springDescription[2],
  );
}

const clampingScrollPhysics = CustomTabBarViewScrollPhysics(
  parent: ClampingScrollPhysics(),
);

class CustomTabBarViewScrollPhysics extends ScrollPhysics {
  const CustomTabBarViewScrollPhysics({super.parent});

  @override
  CustomTabBarViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomTabBarViewScrollPhysics(parent: buildParent(ancestor));
  }

  static final _springDescription = _customSpringDescription();

  @override
  SpringDescription get spring => _springDescription;
}

mixin ReloadMixin {
  late bool reload = false;
}

class ReloadScrollPhysics extends AlwaysScrollableScrollPhysics {
  const ReloadScrollPhysics({super.parent, required this.controller});

  final ReloadMixin controller;

  @override
  ReloadScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ReloadScrollPhysics(
      parent: buildParent(ancestor),
      controller: controller,
    );
  }

  @override
  double adjustPositionForNewDimensions({
    required ScrollMetrics oldPosition,
    required ScrollMetrics newPosition,
    required bool isScrolling,
    required double velocity,
  }) {
    if (controller.reload) {
      controller.reload = false;
      return 0;
    }
    return super.adjustPositionForNewDimensions(
      oldPosition: oldPosition,
      newPosition: newPosition,
      isScrolling: isScrolling,
      velocity: velocity,
    );
  }
}
