import 'color.dart';
import 'size.dart';
import 'package:flutter/material.dart';

double get oneLineH => 1.3;

class StandardTextStyle {
  static const TextStyle big = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: SysSize.big,
    color: ColorPlate.darkGray,
    inherit: true,
    height: 1.4,
  );
  static const TextStyle normalW = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: SysSize.normal,
    color: ColorPlate.darkGray,
    inherit: true,
    height: 1.4,
  );
  static const TextStyle normal = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: SysSize.normal,
    color: ColorPlate.darkGray,
    inherit: true,
    height: 1.4,
  );
  static const TextStyle small = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: SysSize.small,
    color: ColorPlate.gray,
    inherit: true,
    height: 1.4,
  );
}

class StText extends StatelessWidget {
  final String? text;
  final TextStyle? style;
  final TextStyle defaultStyle;
  final TextAlign? align;
  final int? maxLines;

  const StText({
    Key? key,
    this.text,
    this.style,
    required this.defaultStyle,
    this.maxLines,
    this.align,
  }) : super(key: key);

  const StText.small(
    String? text, {
    Key? key,
    TextStyle? style,
    TextAlign? align,
    int? maxLines,
  }) : this(
          key: key,
          text: text,
          style: style,
          defaultStyle: StandardTextStyle.small,
          maxLines: maxLines,
          align: align,
        );

  const StText.normal(
    String? text, {
    Key? key,
    TextStyle? style,
    TextAlign? align,
    int? maxLines,
  }) : this(
          key: key,
          text: text,
          style: style,
          defaultStyle: StandardTextStyle.normal,
          maxLines: maxLines,
          align: align,
        );

  const StText.medium(
    String? text, {
    Key? key,
    TextStyle? style,
    int? maxLines,
  }) : this(
          key: key,
          text: text,
          style: style,
          defaultStyle: StandardTextStyle.normalW,
          maxLines: maxLines,
        );

  const StText.big(
    String? text, {
    Key? key,
    TextStyle? style,
    TextAlign? align,
    int? maxLines,
  }) : this(
          key: key,
          text: text,
          style: style,
          defaultStyle: StandardTextStyle.big,
          maxLines: maxLines,
          align: align,
        );

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: defaultStyle,
      child: Text(
        text ?? '',
        maxLines: maxLines ?? 100,
        textAlign: align,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
    );
  }
}
