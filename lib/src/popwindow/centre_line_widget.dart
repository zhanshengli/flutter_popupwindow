import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

///根据某个组件的中线，绘制组件
class CentreLineWidget extends SingleChildRenderObjectWidget {
  const CentreLineWidget(this.centreLine,
      {Key? key,
      this.centreDiceration = CentreDiceration.horization,
      Widget? child})
      : super(key: key, child: child);

  ///中线位置
  final double centreLine;

  ///居中方向
  final CentreDiceration centreDiceration;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _CentreLineRenderObject(centreLine, centreDiceration);

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderObject renderObject) {
    _CentreLineRenderObject object = renderObject as _CentreLineRenderObject;
    object.centreLine = centreLine;
  }
}

class _CentreLineRenderObject extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  _CentreLineRenderObject(double centreLine, CentreDiceration centreDiceration)
      : _centreLine = centreLine,
        _centreDiceration = centreDiceration;

  double get centreLine => _centreLine!;

  CentreDiceration get centreDiceration => _centreDiceration;
  CentreDiceration _centreDiceration;

  set centreDiceration(CentreDiceration value) {
    if (value == _centreDiceration) return;
    _centreDiceration = value;
    markNeedsPaint();
  }

  set centreLine(double value) {
    if (value == _centreLine) return;
    _centreLine = value;
    markNeedsPaint();
  }

  double? _centreLine;

  Size get parenSize => MediaQueryData.fromWindow(window).size;

  ///状态栏高度
  double get paddingTop => MediaQueryData.fromWindow(window).padding.top;

  ///底部虚拟键高度
  double get paddingBottom => MediaQueryData.fromWindow(window).padding.bottom;

  @override
  void performLayout() {
    if (child == null) {
      size = Size.zero;
    } else {
      child!.layout(constraints, parentUsesSize: true);
      size = constraints.constrain(child!.size);
      BoxParentData parentData = child!.parentData as BoxParentData;
      if (centreDiceration == CentreDiceration.vertical) {
        parentData.offset = cacularHorizontalOffset(size);
      } else {
        parentData.offset = cacularVerticalOffset(size);
      }
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      BoxParentData parentData = child!.parentData as BoxParentData;
      if (centreDiceration == CentreDiceration.horization) {
        context.paintChild(child!, parentData.offset + Offset(offset.dx, 0));
      } else {
        context.paintChild(child!, parentData.offset + Offset(0, offset.dy));
      }
    }
  }

  ///计算水平方向偏移量
  Offset cacularHorizontalOffset(Size size) {
   late Offset offset;
    if (centreLine - size.width / 2 < 0) {
      ///超出屏幕左边缘
      offset = Offset.zero;
    } else if (centreLine + size.width / 2 > parenSize.width) {
      ///超出屏幕右边缘
      offset = Offset(parenSize.width - size.width, 0);
    } else {
      offset = Offset(centreLine - size.width / 2, 0);
    }
    return offset;
  }

  ///计算垂直方向偏移量
  Offset cacularVerticalOffset(Size size) {
    late Offset offset;
    if (centreLine - size.height / 2 < paddingTop) {
      ///超出屏幕顶部通知栏
      offset = Offset(0, paddingTop);
    } else if (centreLine + size.height / 2 >
        (parenSize.height - paddingBottom)) {
      ///超出屏幕下边缘
      offset = Offset(0, parenSize.height - size.height - paddingBottom);
    } else {
      offset = Offset(0, centreLine - size.height / 2);
    }
    return offset;
  }
}

enum CentreDiceration {
  ///垂直线
  vertical,

  ///水平线
  horization
}
