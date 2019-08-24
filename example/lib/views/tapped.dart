import 'package:flutter/material.dart';

class Tapped extends StatefulWidget {
  Tapped({this.child, this.onTap});
  final Widget child;
  final Function onTap;
  @override
  _TappedState createState() => _TappedState();
}

class _TappedState extends State<Tapped> with TickerProviderStateMixin {
  bool isChangeAlpha = false;
  double alpha;

  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    controller = AnimationController(value: 1, vsync: this);
    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    );
    // animation.addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     controller.reverse();
    //   }
    // });
    super.initState();
  }

  bool tapDown = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Duration duration = const Duration(milliseconds: 50);
    Duration showDuration = const Duration(milliseconds: 660);
    animation.addListener(() {
      this.setState(() {});
    });
    return GestureDetector(
      onTap: () async {
        if (widget.onTap != null) {
          await Future.delayed(Duration(milliseconds: 100));
          widget.onTap();
        }
      },
      onTapDown: (detail) async {
        tapDown = true;
        isChangeAlpha = true;
        await controller.animateTo(0.4, duration: duration);
        if (!tapDown) {
          await controller.animateTo(1, duration: showDuration);
        }
        tapDown = false;
        isChangeAlpha = false;
      },
      onTapUp: (detail) async {
        tapDown = false;
        if (isChangeAlpha == true) {
          return;
        }
        await controller.animateTo(1, duration: showDuration);
        isChangeAlpha = false;
      },
      onTapCancel: () async {
        tapDown = false;
        controller.value = 1;
        isChangeAlpha = false;
      },
      child: Opacity(
        opacity: animation.value,
        child: widget.child,
      ),
    );
  }
}
