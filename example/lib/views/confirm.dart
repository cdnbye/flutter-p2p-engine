import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_p2p_engine_example/style/color.dart';
import 'package:flutter_p2p_engine_example/style/size.dart';
import 'package:flutter_p2p_engine_example/style/text.dart';
import 'package:tapped/tapped.dart';

const String titleText = '结果';
const String cancelText = '取消';
const String closeText = '关闭';
const String okText = '确认';

enum ConfirmType {
  info,
  success,
  warning,
  danger,
}

/// 封装了取值，焦点，控制器方法
class InputHelper {
  final String? defaultText;

  InputHelper({this.defaultText})
      : controller = TextEditingController(text: defaultText);

  final TextEditingController controller;

  String get text => controller.value.text;

  set text(String? t) {
    controller.value = TextEditingValue(text: t ?? '');
  }

  final FocusNode focusNode = FocusNode();
}

textOfConfirmType(ConfirmType type) => [
      '提醒',
      '操作成功',
      '警告',
      '警告',
    ][type.index];

/// 输入多行文本，可以通过onWillConfirm方法检查
Future<String?> inputMutiLineText(
  BuildContext context, {
  ConfirmType? type,
  String? text,
  String? title,
  String? hintText,
  String? ok,
  String? cancel,
  Future<bool> Function(String)? onWillConfirm,
}) async {
  InputHelper temp = InputHelper(defaultText: text);
  var res = await confirm(
    context,
    type: type ?? ConfirmType.warning,
    title: title,
    ok: ok,
    cancel: cancel,
    onWillConfirm: () async => (await onWillConfirm?.call(temp.text)) ?? true,
    contentBuilder: (ctx) => StTextField(
      autofocus: true,
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      helper: temp,
      hintText: hintText,
    ),
  );
  if (res == true) {
    return temp.text;
  }
  return null;
}

/// 输入文本，可以通过onWillConfirm方法检查
Future<String?> inputText(
  BuildContext context, {
  ConfirmType? type,
  String? text,
  int? maxLength,
  String? title,
  String? hintText,
  String? ok,
  String? cancel,
  TextInputType? textInputType,
  Future<bool> Function(String)? onWillConfirm,
}) async {
  InputHelper temp = InputHelper(defaultText: text);
  var res = await confirm(
    context,
    type: type,
    title: title,
    ok: ok,
    cancel: cancel,
    onWillConfirm: () async => (await onWillConfirm?.call(temp.text)) ?? true,
    contentBuilder: (ctx) => Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: ColorPlate.lightGray,
        borderRadius: BorderRadius.circular(6),
      ),
      child: StInput.helper(
        autofocus: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        inputType: textInputType,
        maxLength: maxLength ?? 20,
        clearable: true,
        helper: temp,
        hintText: hintText,
      ),
    ),
  );
  if (res == true) {
    return temp.text;
  }
  return null;
}

/// 显示对话窗口
Future<bool?> confirm(
  BuildContext context, {
  String? title,
  String? content,
  Widget Function(BuildContext)? contentBuilder,
  Future<bool> Function()? onWillConfirm,
  String? ok,
  String? cancel,
  ConfirmType? type,
  double? width,
  bool showHeader = true,
  bool onlyCloseButton = false,
  bool onlyContent = false,
  bool barrierDismissible = true,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => _ConfirmDialog(
      title: title,
      content: content,
      contentWidgetBuilder: contentBuilder,
      onWillConfirm: onWillConfirm,
      ok: ok,
      cancel: cancel,
      type: type ?? ConfirmType.info,
      width: width ?? 300,
      onlyCloseButton: onlyCloseButton,
      onlyContent: onlyContent,
      showHeader: showHeader,
    ),
  );
}

class ResMsg<T> {
  final bool success;
  final String msg;
  final T? data;

  ResMsg(this.success, this.msg, this.data);
  ResMsg.success(String msg, [data]) : this(true, msg, data);
  ResMsg.fail(String msg, [data]) : this(false, msg, data);

  @override
  String toString() {
    return 'ResMsg:$success $msg $data';
  }
}

/// 使用ResMsg显示对话窗口
Future<bool?> confirmResMsg(context, ResMsg<dynamic> msg, [String? title]) {
  return confirm(
    context,
    title: title,
    content: msg.msg,
    type: msg.success ? ConfirmType.success : ConfirmType.danger,
  );
}

class _ConfirmDialog extends StatelessWidget {
  final ConfirmType type;
  final String? title;
  final String? content;
  final Widget Function(BuildContext)? contentWidgetBuilder;
  final double width;
  final String? ok;
  final String? cancel;
  final bool onlyCloseButton;
  final bool onlyContent;
  final bool showHeader;
  final Future<bool> Function()? onWillConfirm;

  const _ConfirmDialog({
    Key? key,
    this.title,
    this.content,
    this.ok,
    this.cancel,
    this.type = ConfirmType.info,
    this.width = 300,
    this.onlyCloseButton = false,
    this.contentWidgetBuilder,
    this.onWillConfirm,
    this.onlyContent = false,
    this.showHeader = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData? iconData;
    Color? color;
    switch (type) {
      case ConfirmType.danger:
        iconData = Icons.info;
        color = ColorPlate.red;
        break;
      case ConfirmType.info:
        iconData = Icons.info;
        color = ColorPlate.mainBlue;
        break;
      case ConfirmType.success:
        iconData = Icons.info_outline;
        color = ColorPlate.green;
        break;
      case ConfirmType.warning:
        iconData = Icons.warning;
        color = Colors.orange;
        break;
    }

    Widget icon = Container(
      padding: const EdgeInsets.only(right: 8),
      child: Icon(
        iconData,
        color: color,
        size: 30,
      ),
    );

    return SimpleDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
      title: showHeader
          ? Row(
              children: <Widget>[
                Expanded(
                  child: StText.medium(
                    title ?? textOfConfirmType(type),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                icon,
              ],
            )
          : null,
      children: <Widget>[
        contentWidgetBuilder?.call(context) ??
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              width: width,
              constraints: const BoxConstraints(minHeight: 120),
              child: StText.normal(content ?? ''),
            ),
        if (!onlyContent)
          Container(
            width: width,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _DialogButton(
                    title: onlyCloseButton ? closeText : (cancel ?? cancelText),
                    pimary: false,
                    onTap: () {
                      Navigator.of(context).pop(onlyCloseButton ? null : false);
                    },
                  ),
                ),
                onlyCloseButton
                    ? Container()
                    : Expanded(
                        child: _DialogButton(
                          title: ok ?? okText,
                          color: color,
                          onTap: () async {
                            var refuse = await onWillConfirm?.call();
                            if (refuse == false) {
                              return;
                            }
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ),
              ],
            ),
          )
      ],
    );
  }
}

class _DialogButton extends StatelessWidget {
  final Function? onTap;
  final String? title;
  final Color? color;
  final bool pimary;
  final double? height;
  final double? width;

  const _DialogButton({
    Key? key,
    this.onTap,
    this.title,
    this.pimary = true,
    this.color,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BoxDecoration d;
    if (pimary) {
      d = BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      );
    } else {
      d = BoxDecoration(
        color: ColorPlate.lightGray,
        borderRadius: BorderRadius.circular(6),
      );
    }
    return Tapped(
      onTap: onTap,
      child: Container(
        height: height ?? 36,
        width: width ?? 368,
        margin: const EdgeInsets.fromLTRB(6, 8, 6, 8),
        alignment: Alignment.center,
        decoration: d,
        child: StText.medium(
          title,
          style: TextStyle(
            height: oneLineH,
            color: pimary ? ColorPlate.white : null,
          ),
        ),
      ),
    );
  }
}

class StInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool enabled;
  final bool isPassword;
  final bool onlyNumber;
  final int maxLength;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? inputType;
  final FocusNode? focusNode;
  final TextAlign textAlign;
  final EdgeInsets? contentPadding;
  final bool? clearable;
  final bool? autofocus;

  const StInput({
    Key? key,
    this.controller,
    this.hintText,
    this.enabled = true,
    this.isPassword = false,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
    this.inputType,
    this.maxLength = 20,
    this.textAlign = TextAlign.start,
    this.onlyNumber = false,
    this.contentPadding,
    this.clearable,
    this.autofocus,
  }) : super(key: key);

  StInput.helper({
    Key? key,
    InputHelper? helper,
    this.hintText,
    this.enabled = true,
    this.isPassword = false,
    this.textInputAction,
    this.onSubmitted,
    this.inputType,
    this.maxLength = 20,
    this.textAlign = TextAlign.start,
    this.onlyNumber = false,
    this.contentPadding,
    this.clearable,
    this.autofocus,
  })  : controller = helper?.controller,
        focusNode = helper?.focusNode,
        super(key: key);

  @override
  _StInputState createState() => _StInputState();
}

class _StInputState extends State<StInput> {
  bool get hasClearBtn =>
      widget.controller?.text.isNotEmpty == true &&
      widget.focusNode!.hasFocus &&
      (widget.clearable ?? false);

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(update);
  }

  void update() => setState(() {});

  @override
  void dispose() {
    widget.controller?.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: widget.focusNode,
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: widget.isPassword,
      keyboardType: widget.inputType,
      autofocus: widget.autofocus ?? false,
      keyboardAppearance: Brightness.light,
      textInputAction: widget.textInputAction,
      textAlign: widget.textAlign,
      inputFormatters: <TextInputFormatter>[
            widget.maxLength == 0
                ? LengthLimitingTextInputFormatter(999)
                : LengthLimitingTextInputFormatter(widget.maxLength), //限制长度
          ] +
          (widget.onlyNumber
              ? [
                  FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                ]
              : []),
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        isDense: true,
        hintText: widget.hintText ?? '##Hint Text##',
        contentPadding: widget.contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 8,
            ),
        // border: enabled == false ? InputBorder.none : null,
        suffixIconConstraints: const BoxConstraints(
          minHeight: 26,
        ),
        suffixIcon: hasClearBtn == true
            ? Tapped(
                onTap: () {
                  if (widget.controller != null) {
                    widget.controller!.text = '';
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 2),
                  color: ColorPlate.clear,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  child: const Icon(
                    Icons.cancel,
                    color: ColorPlate.gray,
                    size: 20,
                  ),
                ),
              )
            : null,
        border: InputBorder.none,

        hintStyle: TextStyle(
          height: oneLineH,
          fontSize: SysSize.small,
          color: ColorPlate.gray,
        ),
      ),
    );
  }
}

class StPwInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool enabled;
  final int maxLength;
  final bool onlyNumAndEn;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final TextInputType? inputType;

  const StPwInput({
    Key? key,
    this.controller,
    this.hintText,
    this.enabled = true,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
    this.inputType,
    this.onlyNumAndEn = false,
    this.maxLength = 20,
  }) : super(key: key);

  @override
  _StPwInputState createState() => _StPwInputState();
}

class _StPwInputState extends State<StPwInput> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: <Widget>[
        TextField(
          focusNode: widget.focusNode,
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: !showPassword,
          keyboardAppearance: Brightness.light,
          keyboardType: widget.inputType,
          textInputAction: widget.textInputAction,
          onSubmitted: widget.onSubmitted,
          inputFormatters: <TextInputFormatter>[
                // WhitelistingTextInputFormatter.digitsOnly, //只输入数字
                widget.maxLength == 0
                    ? LengthLimitingTextInputFormatter(999)
                    : LengthLimitingTextInputFormatter(widget.maxLength), //限制长度
              ] +
              (widget.onlyNumAndEn
                  ? [
                      FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
                    ]
                  : []),
          decoration: InputDecoration(
            isDense: true,
            hintText: widget.hintText ?? '##Hint Text##',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 6,
            ),
            border: widget.enabled == false ? InputBorder.none : null,
            hintStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: ColorPlate.gray,
            ),
          ),
        ),
        Tapped(
          onTap: () {
            setState(() => showPassword = !showPassword);
          },
          child: Container(
            height: 40,
            width: 40,
            color: ColorPlate.clear,
            child: Center(
              child: Icon(
                Icons.remove_red_eye,
                color: showPassword
                    ? ColorPlate.mainBlue
                    : ColorPlate.gray.withOpacity(0.5),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class StTextField extends StatelessWidget {
  final InputHelper? helper;
  final String? hintText;
  final bool? autofocus;
  final int? max;
  final int? minLines;
  final int? maxLines;
  final EdgeInsets? margin;
  final Widget? Function(
    BuildContext context, {
    required int currentLength,
    required int? maxLength,
    required bool isFocused,
  })? buildCounter;
  const StTextField({
    Key? key,
    this.helper,
    this.hintText,
    this.margin,
    this.autofocus,
    this.max = 900,
    this.minLines,
    this.maxLines,
    this.buildCounter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          color: ColorPlate.lightGray,
          child: TextField(
            focusNode: helper?.focusNode,
            controller: helper?.controller,
            autofocus: autofocus == true,
            keyboardAppearance: Brightness.light,
            minLines: minLines ?? 3,
            maxLines: maxLines ?? 20,
            maxLength: max,
            keyboardType: TextInputType.multiline,
            inputFormatters: [
              LengthLimitingTextInputFormatter(max),
            ],
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText ?? '请填写内容',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: InputBorder.none,
              hintStyle: TextStyle(
                height: oneLineH,
                fontSize: SysSize.normal,
                color: ColorPlate.gray,
              ),
            ),
            buildCounter: buildCounter,
          ),
        ),
      ),
    );
  }
}
