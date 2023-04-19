import 'dart:collection';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'anchor_custom_paint.dart';
import 'anchor_custom_painter.dart';

///默认三角形底边宽度
const double kAnchorWidth = 10;

///默认三角形高度
const double kAnchorHeight = 10;

class AnchorWidget extends StatelessWidget {
  AnchorWidget({
    Key? key,
    this.child,
    this.color = Colors.white,
    this.width,
    this.height,
    this.anchor,
    this.showAnchor = true,
    this.location = AnchorDirection.top,
  })  : assert(width == null || width >= 0),
        assert(height == null || height >= 0),
        assert(anchor == null || anchor >= 0),
        super(key: key);

  final Color color;

  final Widget? child;

  ///三角形底边的宽度
  final double? width;

  ///三角形的高度
  final double? height;

  ///三角形方向(默认向上)
  final AnchorDirection? location;

  ///三角形标的锚点（根据给定的位置，显示三角形标）
  ///屏幕左上角为原点
  final double? anchor;

  ///是否显示角标
  final bool showAnchor;

  late AnchorPaiter paiter = AnchorPaiter();

  @override
  Widget build(BuildContext context) {
    if (showAnchor) {
      paiter
        ..color = color
        ..width = width
        ..height = height
        ..location = location ?? AnchorDirection.top
        ..anchor = anchor;
    }
    return AnchorCustomPaint(
      painter: showAnchor ? paiter : null,
      child: child,
    );
  }
}

class AnchorPaiter extends AnchorCustomPainter {
  ///三角形标的锚点
  double? get anchor => _anchor;
  double? _anchor;

  set anchor(double? value) {
    _anchor = value;
  }

  ///三角形底的宽度
  double get width => _width!;
  double? _width;

  set width(double? value) {
    _width = value ?? kAnchorWidth;
  }

  ///三角形的高度
  double get height => _height!;
  double? _height;

  set height(double? value) {
    _height = value ?? kAnchorHeight;
  }

  ///三角形的位置，上下左右
  AnchorDirection get location => _location!;
  AnchorDirection? _location;

  set location(AnchorDirection? value) {
    _location = value;
  }

  Color get color => _color!;
  Color? _color;

  set color(Color value) {
    _color = value;
  }

  ///三角形三个顶点坐标
  late Offset _offset1;
  late Offset _offset2;
  late Offset _offset3;

  Paint painter = Paint()..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  ///计算三角形底边最小宽度
  double cacularMinWidth(Size size) {
    double minWidth = 0;
    switch (location) {
      case AnchorDirection.bottom:
      case AnchorDirection.top:
        minWidth = min(size.width, width);
        break;
      case AnchorDirection.left:
      case AnchorDirection.right:
        minWidth = min(size.height, width);
        break;
    }
    return minWidth;
  }

  ///计算三角形三个顶点坐标
  void cacularOffset(double minWidth, Size size, Offset offset) {
    double center = cacularCenter(minWidth, size, offset);
    switch (location) {
      case AnchorDirection.bottom:
        _offset1 = Offset(center - minWidth / 2, offset.dy + size.height);
        _offset2 = Offset(center + minWidth / 2, offset.dy + size.height);
        _offset3 = Offset(center, size.height + offset.dy + height);
        break;
      case AnchorDirection.top:
        _offset1 = Offset(center - minWidth / 2, offset.dy);
        _offset2 = Offset(center + minWidth / 2, offset.dy);
        _offset3 = Offset(center, offset.dy - height);
        break;
      case AnchorDirection.left:
        _offset1 = Offset(offset.dx, center - minWidth / 2);
        _offset2 = Offset(offset.dx, center + minWidth / 2);
        _offset3 = Offset(offset.dx - height, center);
        break;
      case AnchorDirection.right:
        _offset1 = Offset(offset.dx + size.width, center - minWidth / 2);
        _offset2 = Offset(offset.dx + size.width, center + minWidth / 2);
        _offset3 = Offset(offset.dx + size.width + height, center);
        break;
    }
  }

  ///计算角标中线位置
  double cacularCenter(double minWidth, Size size, Offset offset) {
    double center = 0;
    if (location == AnchorDirection.top || location == AnchorDirection.bottom) {
      if (anchor != null) {
        center = anchor!;
      } else {
        center = offset.dx + size.width / 2;
      }
    } else {
      if (anchor != null) {
        center = anchor!;
      } else {
        center = offset.dy + size.height / 2;
      }
    }
    return center;
  }

  @override
  void paint2(Canvas canvas, Size size, Offset offset) {
    if (size == Size.zero || size.isEmpty) return;
    painter.color = color;
    canvas.restore();
    Path path = Path();
    double minWidth = cacularMinWidth(size);

    ///计算三角形三个顶点坐标
    cacularOffset(minWidth, size, offset);
    path.moveTo(_offset1.dx, _offset1.dy);
    path.lineTo(_offset2.dx, _offset2.dy);
    path.lineTo(_offset3.dx, _offset3.dy);
    canvas.drawPath(path, painter);
    canvas.save();
  }
}

///三角形位置
enum AnchorDirection { left, top, right, bottom }
