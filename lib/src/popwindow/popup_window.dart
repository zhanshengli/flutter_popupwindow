import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'centre_line_widget.dart';
import 'custompaint/anchor_widget.dart';

double kPopWindowHeight = 280;

class PopupWindow<T> extends PopupRoute<T> {
  PopupWindow(
      {required this.popBuilder,
      required this.key,
      this.contentWidth,
      this.contentHeight,
      this.space = 5,
      this.showBarrier = false,
      this.dismissible = true,
      this.showAnchor = true,
      this.margin,
      this.anchorWidth,
      this.anchorHeight,
      required this.padding,
      this.decoration,
      this.location = PopLocation.bottom,
      this.duration = const Duration(milliseconds: 100)})
      : assert(duration != null),
        assert(location != null, "请设置显示位置"),
        assert(contentWidth == null || contentWidth > 0);

  final Duration? duration;

  ///设置圆角，背景颜色
  final BoxDecoration? decoration;
  final RoutePageBuilder popBuilder;
  final double? contentWidth; //内容区域宽度
  final double? contentHeight; //内容区域高度
  final PopLocation location; //显示位置，上下左右，默认向下
  final GlobalKey key; //锚点组件的key
  ///锚点和内容之间的间距
  final double space;
  final EdgeInsetsGeometry padding;
  final EdgeInsets? margin;

  ///是否显示遮罩
  final bool showBarrier;

  ///是否显示角标
  final bool showAnchor;

  ///三角形底边宽度
  final double? anchorWidth;

  ///三角形高度
  final double? anchorHeight;

  ///点击遮罩是否关闭
  final bool dismissible;

  double? offLeft, offTop, offRight, offBottom; //上下左右偏移量

  @override
  Color? get barrierColor => showBarrier ? const Color(0x80000000) : null;

  @override
  bool get barrierDismissible => dismissible;

  @override
  String? get barrierLabel => "pop";

  ///状态栏高度
  double get paddingTop => MediaQueryData.fromWindow(window).padding.top;

  ///底部虚拟键高度
  double get paddingBottom => MediaQueryData.fromWindow(window).padding.bottom;

  ///屏幕大小
  Size get parentSize => MediaQueryData.fromWindow(window).size;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    RenderBox? renderObject =
        key.currentContext?.findRenderObject() as RenderBox?;
    assert(renderObject != null);

    ///锚点size
    Size anchorSize = renderObject!.size;

    ///锚点组件的中心点
    Offset anchorCenter = renderObject.paintBounds.center;

    ///屏幕位置偏移（屏幕左上角为原点）
    Offset globleOffset = renderObject.localToGlobal(Offset.zero);

    ///锚点组件全局水平线（屏幕左上角为原点）
    double anchorHoriLine = anchorCenter.dy + globleOffset.dy;

    ///锚点组件全局垂直线（屏幕左上角为原点）
    double anchorVerLine = getVerLine(anchorCenter, globleOffset);

    CentreDiceration centreDiceration =
        location == PopLocation.left || location == PopLocation.right
            ? CentreDiceration.horization
            : CentreDiceration.vertical;

    ///最大宽度
    double maxWidth = cacularMaxContentWidth(anchorSize, globleOffset);

    ///最小宽度
    double minWidth = cacularMinContentWidth(maxWidth, anchorSize);

    ///最大高度
    double maxHeiht = cacularMaxContentHeight(anchorSize, globleOffset);

    ///最小高度
    double minHeight = getMinContentHeight(maxHeiht, anchorSize);

    ///角标方向
    AnchorDirection? anchorDirection;
    if (showAnchor) anchorDirection = cacularAnchorDirection(location);

    ///pop内容
    Widget content = CentreLineWidget(
      centreDiceration == CentreDiceration.horization
          ? anchorHoriLine
          : anchorVerLine,
      centreDiceration: centreDiceration,
      child: Container(
        margin: margin,
        constraints: BoxConstraints(
            minHeight: minHeight,
            maxHeight: maxHeiht,
            minWidth: minWidth,
            maxWidth: maxWidth),
        // padding: padding,
        decoration: decoration,
        child: AnchorWidget(
          color: decoration?.color ?? Colors.white,
          location: anchorDirection,
          width: anchorWidth,
          height: anchorHeight,
          anchor: centreDiceration == CentreDiceration.horization
              ? anchorHoriLine
              : anchorCenter.dx + globleOffset.dx,
          showAnchor: showAnchor,
          child: Padding(
            padding: padding,
            child: Align(
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: popBuilder(context, animation, secondaryAnimation),
            ),
          ),
        ),
      ),
    );

    dealOffset(anchorSize, globleOffset, parentSize);

    return Stack(
      children: [
        Positioned(
          top: offTop,
          bottom: offBottom,
          left: offLeft,
          right: offRight,
          child: content,
        )
      ],
    );
  }

  ///位置是上下模式时，当dialog全屏显示，垂直中心在屏幕中心
  double getVerLine(Offset anchorCenter, Offset globleOffset) {
    double verline = 0;
    if ((location == PopLocation.top || location == PopLocation.bottom) &&
        contentWidth == double.infinity) {
      verline = parentSize.width / 2;
    } else {
      verline = anchorCenter.dx + globleOffset.dx;
    }
    return verline;
  }

  ///计算最大高度
  double cacularMaxContentHeight(Size? anchorSize, Offset globle) {
    if (anchorSize == null) return 0;
    double maxHeight = getMaxContentHeight(parentSize, globle, anchorSize);
    if (contentHeight?.isFinite == true) return min(contentHeight!, maxHeight);
    return maxHeight;
  }

  ///最大高度
  double getMaxContentHeight(Size parentSize, Offset globle, Size anchorSize) {
    double maxHeiht = 0;
    double verMargin = margin?.vertical ?? 0;

    ///三角形指示器的高度
    double indicatorHeight = showAnchor ? (anchorHeight ?? kAnchorHeight) : 0;
    switch (location) {
      case PopLocation.bottom:
        maxHeiht = (parentSize.height -
                globle.dy -
                anchorSize.height -
                space -
                indicatorHeight -
                paddingBottom -
                verMargin)
            .clamp(0, parentSize.height);
        break;
      case PopLocation.top:
        maxHeiht =
            (globle.dy - space - paddingTop - verMargin - indicatorHeight)
                .clamp(0, globle.dy);
        break;
      default:
        maxHeiht = kPopWindowHeight;
        break;
    }
    return maxHeiht;
  }

  ///最小高度
  double getMinContentHeight(double maxHeight, Size anchorSize) {
    double minHeight = 0;
    switch (location) {
      case PopLocation.top:
      case PopLocation.bottom:
        minHeight = contentHeight?.isFinite == true
            ? min(maxHeight, contentHeight!)
            : 0;
        break;
      case PopLocation.left:
      case PopLocation.right:
        minHeight = contentHeight == null || contentHeight == double.infinity
            ? anchorSize.height
            : min(maxHeight, contentHeight!);
        break;
    }
    return minHeight;
  }

  ///计算最大宽度
  double cacularMaxContentWidth(Size? anchorSize, Offset globle) {
    if (anchorSize == null) return 0;
    return getMaxContentWidth(globle, anchorSize);
  }

  ///最大宽度
  double getMaxContentWidth(Offset globle, Size anchorSize) {
    double maxWidth = 0;
    double edageMargin = margin?.horizontal ?? 0;
    double edageLeft = margin?.left ?? 0;
    double edageRight = margin?.right ?? 0;

    ///三角形指示器的高度
    double indicatorHeight = showAnchor ? (anchorHeight ?? kAnchorHeight) : 0;
    switch (location) {
      case PopLocation.left:
        maxWidth = (globle.dx - space - edageMargin - indicatorHeight)
            .clamp(0, globle.dx);
        break;
      case PopLocation.right:
        maxWidth = (parentSize.width -
                globle.dx -
                anchorSize.width -
                space -
                edageMargin -
                indicatorHeight)
            .clamp(0, parentSize.width - globle.dx);
        break;
      default:
        maxWidth = contentWidth == null
            ? anchorSize.width
            : (contentWidth == double.infinity
                ? parentSize.width - edageMargin
                : contentWidth!);
        break;
    }
    return maxWidth;
  }

  ///最小宽度
  double cacularMinContentWidth(double maxWidth, Size anchorSize) {
    double minWidth = 0;
    double edageMargin = margin?.horizontal ?? 0;
    switch (location) {
      case PopLocation.left:
      case PopLocation.right:
        minWidth =
            contentWidth?.isFinite == true ? min(contentWidth!, maxWidth) : 0;
        break;
      default:
        minWidth = contentWidth == null
            ? anchorSize.width
            : (contentWidth == double.infinity
                ? parentSize.width - edageMargin
                : contentWidth!);
        break;
    }
    return minWidth;
  }

  ///处理content偏移
  void dealOffset(Size anchorSize, Offset globle, Size parentSize) {
    ///三角形指示器的高度
    double indicatorHeight = showAnchor ? (anchorHeight ?? kAnchorHeight) : 0;
    switch (location) {
      case PopLocation.bottom:
        offBottom = null;
        offTop = globle.dy + space + anchorSize.height + indicatorHeight;
        offLeft = null;
        offRight = null;
        break;
      case PopLocation.top:
        offTop = null;
        offBottom = parentSize.height - globle.dy + space + indicatorHeight;
        offLeft = null;
        offRight = null;
        break;
      case PopLocation.left:
        offLeft = null;
        offRight = parentSize.width - globle.dx + space + indicatorHeight;
        offBottom = null;
        offTop = null;
        break;
      case PopLocation.right:
        offRight = null;
        offLeft = globle.dx + space + anchorSize.width + indicatorHeight;
        offBottom = null;
        offTop = null;
        break;
    }
  }

  @override
  Duration get transitionDuration => duration!;

  AnchorDirection? cacularAnchorDirection(PopLocation location) {
    AnchorDirection? direction;
    switch (location) {
      case PopLocation.left:
        direction = AnchorDirection.right;
        break;
      case PopLocation.top:
        direction = AnchorDirection.bottom;
        break;
      case PopLocation.right:
        direction = AnchorDirection.left;
        break;
      case PopLocation.bottom:
        direction = AnchorDirection.top;
        break;
    }
    return direction;
  }
}

enum PopLocation {
  left,
  top,
  right,
  bottom,
}

Future showPopWindow(
    GlobalKey key, BuildContext context, RoutePageBuilder builder,
    {PopLocation location = PopLocation.bottom,
    double space = 5,
    double? height,
    double? width,
    EdgeInsetsGeometry padding = const EdgeInsets.all(10),
    bool showBarrer = false,
    bool showAnchor = true,
    bool dismissible = true,
    EdgeInsets? margin = const EdgeInsets.all(5),
    BoxDecoration? decoration = const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5)))}) {
  return Navigator.push(
      context,
      PopupWindow(
          key: key,
          popBuilder: builder,
          location: location,
          decoration: decoration,
          contentHeight: height,
          space: space,
          padding: padding,
          dismissible: dismissible,
          margin: margin,
          showBarrier: showBarrer,
          showAnchor: showAnchor,
          contentWidth: width));
}
