import 'package:flutter/services.dart';

import 'color.dart';
import 'size.dart';
import 'package:flutter/material.dart';

class MyTheme {
  static ThemeData standard = ThemeData(
      brightness: Brightness.light,
      hintColor: ColorPlate.mainBlue,
      textTheme: TextTheme(
        //设置Material的默认字体样式
        bodyMedium: TextStyle(
          color: ColorPlate.darkGray,
          fontSize: SysSize.normal,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        color: ColorPlate.white,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(
          color: ColorPlate.darkGray,
        ),
      ),
      primaryColor: ColorPlate.mainBlue,
      // primaryColorBrightness: Brightness.dark,
      scaffoldBackgroundColor: ColorPlate.white,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: ColorPlate.mainBlue,
        selectionColor: ColorPlate.highLightBlue.withOpacity(0.5),
        selectionHandleColor: ColorPlate.highLightBlue,
      )
      // inputDecorationTheme: InputDecorationTheme(
      // ),
      // highlightColor: Colors.transparent,
      // splashFactory: const NoSplashFactory(),
      );
}

class NoSplashFactory extends InteractiveInkFeatureFactory {
  const NoSplashFactory();

  InteractiveInkFeature create({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required Offset position,
    required Color color,
    TextDirection? textDirection,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    double? radius,
    VoidCallback? onRemoved,
  }) {
    return NoSplash(
      controller: controller,
      referenceBox: referenceBox,
      color: color,
      onRemoved: onRemoved,
    );
  }
}

class NoSplash extends InteractiveInkFeature {
  NoSplash({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required Color color,
    VoidCallback? onRemoved,
  }) : super(
          controller: controller,
          referenceBox: referenceBox,
          onRemoved: onRemoved,
          color: color,
        ) {
    controller.addInkFeature(this);
  }
  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {}
}
