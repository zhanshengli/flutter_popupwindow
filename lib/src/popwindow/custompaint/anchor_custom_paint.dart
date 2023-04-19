import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'anchor_custom_painter.dart';

class AnchorCustomPaint extends SingleChildRenderObjectWidget {
  /// Creates a widget that delegates its painting.
  const AnchorCustomPaint({
    Key? key,
    this.painter,
    this.foregroundPainter,
    this.size = Size.zero,
    this.isComplex = false,
    this.willChange = false,
    Widget? child,
  })  : assert(size != null),
        assert(isComplex != null),
        assert(willChange != null),
        assert(painter != null ||
            foregroundPainter != null ||
            (!isComplex && !willChange)),
        super(key: key, child: child);

  /// The painter that paints before the children.
  final AnchorCustomPainter? painter;

  final AnchorCustomPainter? foregroundPainter;

  /// The size that this [CustomPaint] should aim for, given the layout
  /// constraints, if there is no child.
  ///
  /// Defaults to [Size.zero].
  ///
  /// If there's a child, this is ignored, and the size of the child is used
  /// instead.
  final Size size;

  /// Whether the painting is complex enough to benefit from caching.
  ///
  /// The compositor contains a raster cache that holds bitmaps of layers in
  /// order to avoid the cost of repeatedly rendering those layers on each
  /// frame. If this flag is not set, then the compositor will apply its own
  /// heuristics to decide whether the this layer is complex enough to benefit
  /// from caching.
  ///
  /// This flag can't be set to true if both [painter] and [foregroundPainter]
  /// are null because this flag will be ignored in such case.
  final bool isComplex;

  /// Whether the raster cache should be told that this painting is likely
  /// to change in the next frame.
  ///
  /// This flag can't be set to true if both [painter] and [foregroundPainter]
  /// are null because this flag will be ignored in such case.
  final bool willChange;

  @override
  _AnchorRenderCustomPaint createRenderObject(BuildContext context) {
    return _AnchorRenderCustomPaint(
      painter: painter,
      foregroundPainter: foregroundPainter,
      preferredSize: size,
      isComplex: isComplex,
      willChange: willChange,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _AnchorRenderCustomPaint renderObject) {
    renderObject
      ..painter = painter
      ..foregroundPainter = foregroundPainter
      ..preferredSize = size
      ..isComplex = isComplex
      ..willChange = willChange;
  }

  @override
  void didUnmountRenderObject(_AnchorRenderCustomPaint renderObject) {
    renderObject
      ..painter = null
      ..foregroundPainter = null;
  }
}

class _AnchorRenderCustomPaint extends RenderProxyBox {
  /// Creates a render object that delegates its painting.
  _AnchorRenderCustomPaint({
    AnchorCustomPainter? painter,
    AnchorCustomPainter? foregroundPainter,
    Size preferredSize = Size.zero,
    this.isComplex = false,
    this.willChange = false,
    RenderBox? child,
  })  : assert(preferredSize != null),
        _painter = painter,
        _foregroundPainter = foregroundPainter,
        _preferredSize = preferredSize,
        super(child);

  /// The background custom paint delegate.
  ///
  /// This painter, if non-null, is called to paint behind the children.
  AnchorCustomPainter? get painter => _painter;
  AnchorCustomPainter? _painter;

  /// Set a new background custom paint delegate.
  ///
  /// If the new delegate is the same as the previous one, this does nothing.
  ///
  /// If the new delegate is the same class as the previous one, then the new
  /// delegate has its [CustomPainter.shouldRepaint] called; if the result is
  /// true, then the delegate will be called.
  ///
  /// If the new delegate is a different class than the previous one, then the
  /// delegate will be called.
  ///
  /// If the new value is null, then there is no background custom painter.
  set painter(AnchorCustomPainter? value) {
    if (_painter == value) return;
    final AnchorCustomPainter? oldPainter = _painter;
    _painter = value;
    _didUpdatePainter(_painter, oldPainter);
  }

  /// The foreground custom paint delegate.
  ///
  /// This painter, if non-null, is called to paint in front of the children.
  AnchorCustomPainter? get foregroundPainter => _foregroundPainter;
  AnchorCustomPainter? _foregroundPainter;

  /// Set a new foreground custom paint delegate.
  ///
  /// If the new delegate is the same as the previous one, this does nothing.
  ///
  /// If the new delegate is the same class as the previous one, then the new
  /// delegate has its [CustomPainter.shouldRepaint] called; if the result is
  /// true, then the delegate will be called.
  ///
  /// If the new delegate is a different class than the previous one, then the
  /// delegate will be called.
  ///
  /// If the new value is null, then there is no foreground custom painter.
  set foregroundPainter(AnchorCustomPainter? value) {
    if (_foregroundPainter == value) return;
    final AnchorCustomPainter? oldPainter = _foregroundPainter;
    _foregroundPainter = value;
    _didUpdatePainter(_foregroundPainter, oldPainter);
  }

  void _didUpdatePainter(
      AnchorCustomPainter? newPainter, AnchorCustomPainter? oldPainter) {
    // Check if we need to repaint.
    if (newPainter == null) {
      assert(oldPainter != null); // We should be called only for changes.
      markNeedsPaint();
    } else if (oldPainter == null ||
        newPainter.runtimeType != oldPainter.runtimeType ||
        newPainter.shouldRepaint(oldPainter)) {
      markNeedsPaint();
    }
    if (attached) {
      oldPainter?.removeListener(markNeedsPaint);
      newPainter?.addListener(markNeedsPaint);
    }

    // Check if we need to rebuild semantics.
    if (newPainter == null) {
      assert(oldPainter != null); // We should be called only for changes.
      if (attached) markNeedsSemanticsUpdate();
    } else if (oldPainter == null ||
        newPainter.runtimeType != oldPainter.runtimeType ||
        newPainter.shouldRebuildSemantics(oldPainter)) {
      markNeedsSemanticsUpdate();
    }
  }

  /// The size that this [RenderCustomPaint] should aim for, given the layout
  /// constraints, if there is no child.
  ///
  /// Defaults to [Size.zero].
  ///
  /// If there's a child, this is ignored, and the size of the child is used
  /// instead.
  Size get preferredSize => _preferredSize;
  Size _preferredSize;

  set preferredSize(Size value) {
    assert(value != null);
    if (preferredSize == value) return;
    _preferredSize = value;
    markNeedsLayout();
  }

  /// Whether to hint that this layer's painting should be cached.
  ///
  /// The compositor contains a raster cache that holds bitmaps of layers in
  /// order to avoid the cost of repeatedly rendering those layers on each
  /// frame. If this flag is not set, then the compositor will apply its own
  /// heuristics to decide whether the this layer is complex enough to benefit
  /// from caching.
  bool isComplex;

  /// Whether the raster cache should be told that this painting is likely
  /// to change in the next frame.
  bool willChange;

  @override
  double computeMinIntrinsicWidth(double height) {
    if (child == null)
      return preferredSize.width.isFinite ? preferredSize.width : 0;
    return super.computeMinIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (child == null)
      return preferredSize.width.isFinite ? preferredSize.width : 0;
    return super.computeMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (child == null)
      return preferredSize.height.isFinite ? preferredSize.height : 0;
    return super.computeMinIntrinsicHeight(width);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (child == null)
      return preferredSize.height.isFinite ? preferredSize.height : 0;
    return super.computeMaxIntrinsicHeight(width);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _painter?.addListener(markNeedsPaint);
    _foregroundPainter?.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _painter?.removeListener(markNeedsPaint);
    _foregroundPainter?.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (_foregroundPainter != null &&
        (_foregroundPainter!.hitTest(position) ?? false)) return true;
    return super.hitTestChildren(result, position: position);
  }

  @override
  bool hitTestSelf(Offset position) {
    return _painter != null && (_painter!.hitTest(position) ?? true);
  }

  @override
  void performLayout() {
    BoxConstraints constraints = this.constraints;
    super.performLayout();
    markNeedsSemanticsUpdate();
  }

  @override
  Size computeSizeForNoChild(BoxConstraints constraints) {
    Size size = constraints.constrain(preferredSize);
    return size;
  }

  void _paintWithPainter(
      Canvas canvas, Offset offset, AnchorCustomPainter painter) {
    late int debugPreviousCanvasSaveCount;
    canvas.save();
    assert(() {
      debugPreviousCanvasSaveCount = canvas.getSaveCount();
      return true;
    }());
    if (offset != Offset.zero) canvas.translate(offset.dx, offset.dy);
    painter.paint2(canvas, size, offset);
    assert(() {
      // This isn't perfect. For example, we can't catch the case of
      // someone first restoring, then setting a transform or whatnot,
      // then saving.
      // If this becomes a real problem, we could add logic to the
      // Canvas class to lock the canvas at a particular save count
      // such that restore() fails if it would take the lock count
      // below that number.
      final int debugNewCanvasSaveCount = canvas.getSaveCount();
      if (debugNewCanvasSaveCount > debugPreviousCanvasSaveCount) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'The $painter custom painter called canvas.save() or canvas.saveLayer() at least '
            '${debugNewCanvasSaveCount - debugPreviousCanvasSaveCount} more '
            'time${debugNewCanvasSaveCount - debugPreviousCanvasSaveCount == 1 ? '' : 's'} '
            'than it called canvas.restore().',
          ),
          ErrorDescription(
              'This leaves the canvas in an inconsistent state and will probably result in a broken display.'),
          ErrorHint(
              'You must pair each call to save()/saveLayer() with a later matching call to restore().'),
        ]);
      }
      if (debugNewCanvasSaveCount < debugPreviousCanvasSaveCount) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'The $painter custom painter called canvas.restore() '
            '${debugPreviousCanvasSaveCount - debugNewCanvasSaveCount} more '
            'time${debugPreviousCanvasSaveCount - debugNewCanvasSaveCount == 1 ? '' : 's'} '
            'than it called canvas.save() or canvas.saveLayer().',
          ),
          ErrorDescription(
              'This leaves the canvas in an inconsistent state and will result in a broken display.'),
          ErrorHint(
              'You should only call restore() if you first called save() or saveLayer().'),
        ]);
      }
      return debugNewCanvasSaveCount == debugPreviousCanvasSaveCount;
    }());
    canvas.restore();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_painter != null) {
      _paintWithPainter(context.canvas, offset, _painter!);
      _setRasterCacheHints(context);
    }
    super.paint(context, offset);
    if (_foregroundPainter != null) {
      _paintWithPainter(context.canvas, offset, _foregroundPainter!);
      _setRasterCacheHints(context);
    }
  }

  void _setRasterCacheHints(PaintingContext context) {
    if (isComplex) context.setIsComplexHint();
    if (willChange) context.setWillChangeHint();
  }

  /// Builds semantics for the picture drawn by [painter].
  SemanticsBuilderCallback? _backgroundSemanticsBuilder;

  /// Builds semantics for the picture drawn by [foregroundPainter].
  SemanticsBuilderCallback? _foregroundSemanticsBuilder;

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    _backgroundSemanticsBuilder = painter?.semanticsBuilder;
    _foregroundSemanticsBuilder = foregroundPainter?.semanticsBuilder;
    config.isSemanticBoundary = _backgroundSemanticsBuilder != null ||
        _foregroundSemanticsBuilder != null;
  }

  /// Describe the semantics of the picture painted by the [painter].
  List<SemanticsNode>? _backgroundSemanticsNodes;

  /// Describe the semantics of the picture painted by the [foregroundPainter].
  List<SemanticsNode>? _foregroundSemanticsNodes;

  @override
  void assembleSemanticsNode(
    SemanticsNode node,
    SemanticsConfiguration config,
    Iterable<SemanticsNode> children,
  ) {
    assert(() {
      if (child == null && children.isNotEmpty) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            '$runtimeType does not have a child widget but received a non-empty list of child SemanticsNode:\n'
            '${children.join('\n')}',
          ),
        ]);
      }
      return true;
    }());

    final List<CustomPainterSemantics> backgroundSemantics =
        _backgroundSemanticsBuilder != null
            ? _backgroundSemanticsBuilder!(size)
            : const <CustomPainterSemantics>[];
    _backgroundSemanticsNodes = _updateSemanticsChildren(
        _backgroundSemanticsNodes, backgroundSemantics);

    final List<CustomPainterSemantics> foregroundSemantics =
        _foregroundSemanticsBuilder != null
            ? _foregroundSemanticsBuilder!(size)
            : const <CustomPainterSemantics>[];
    _foregroundSemanticsNodes = _updateSemanticsChildren(
        _foregroundSemanticsNodes, foregroundSemantics);

    final bool hasBackgroundSemantics = _backgroundSemanticsNodes != null &&
        _backgroundSemanticsNodes!.isNotEmpty;
    final bool hasForegroundSemantics = _foregroundSemanticsNodes != null &&
        _foregroundSemanticsNodes!.isNotEmpty;
    final List<SemanticsNode> finalChildren = <SemanticsNode>[
      if (hasBackgroundSemantics) ..._backgroundSemanticsNodes!,
      ...children,
      if (hasForegroundSemantics) ..._foregroundSemanticsNodes!,
    ];
    super.assembleSemanticsNode(node, config, finalChildren);
  }

  @override
  void clearSemantics() {
    super.clearSemantics();
    _backgroundSemanticsNodes = null;
    _foregroundSemanticsNodes = null;
  }

  /// Updates the nodes of `oldSemantics` using data in `newChildSemantics`, and
  /// returns a new list containing child nodes sorted according to the order
  /// specified by `newChildSemantics`.
  ///
  /// [SemanticsNode]s that match [CustomPainterSemantics] by [Key]s preserve
  /// their [SemanticsNode.key] field. If a node with the same key appears in
  /// a different position in the list, it is moved to the new position, but the
  /// same object is reused.
  ///
  /// [SemanticsNode]s whose `key` is null may be updated from
  /// [CustomPainterSemantics] whose `key` is also null. However, the algorithm
  /// does not guarantee it. If your semantics require that specific nodes are
  /// updated from specific [CustomPainterSemantics], it is recommended to match
  /// them by specifying non-null keys.
  ///
  /// The algorithm tries to be as close to [RenderObjectElement.updateChildren]
  /// as possible, deviating only where the concepts diverge between widgets and
  /// semantics. For example, a [SemanticsNode] can be updated from a
  /// [CustomPainterSemantics] based on `Key` alone; their types are not
  /// considered because there is only one type of [SemanticsNode]. There is no
  /// concept of a "forgotten" node in semantics, deactivated nodes, or global
  /// keys.
  static List<SemanticsNode> _updateSemanticsChildren(
    List<SemanticsNode>? oldSemantics,
    List<CustomPainterSemantics>? newChildSemantics,
  ) {
    oldSemantics = oldSemantics ?? const <SemanticsNode>[];
    newChildSemantics = newChildSemantics ?? const <CustomPainterSemantics>[];

    assert(() {
      final Map<Key, int> keys = HashMap<Key, int>();
      final List<DiagnosticsNode> information = <DiagnosticsNode>[];
      for (int i = 0; i < newChildSemantics!.length; i += 1) {
        final CustomPainterSemantics child = newChildSemantics[i];
        if (child.key != null) {
          if (keys.containsKey(child.key)) {
            information.add(ErrorDescription(
                '- duplicate key ${child.key} found at position $i'));
          }
          keys[child.key!] = i;
        }
      }

      if (information.isNotEmpty) {
        information.insert(
            0,
            ErrorSummary(
                'Failed to update the list of CustomPainterSemantics:'));
        throw FlutterError.fromParts(information);
      }

      return true;
    }());

    int newChildrenTop = 0;
    int oldChildrenTop = 0;
    int newChildrenBottom = newChildSemantics.length - 1;
    int oldChildrenBottom = oldSemantics.length - 1;

    final List<SemanticsNode?> newChildren =
        List<SemanticsNode?>.filled(newChildSemantics.length, null);

    // Update the top of the list.
    while ((oldChildrenTop <= oldChildrenBottom) &&
        (newChildrenTop <= newChildrenBottom)) {
      final SemanticsNode oldChild = oldSemantics[oldChildrenTop];
      final CustomPainterSemantics newSemantics =
          newChildSemantics[newChildrenTop];
      if (!_canUpdateSemanticsChild(oldChild, newSemantics)) break;
      final SemanticsNode newChild =
          _updateSemanticsChild(oldChild, newSemantics);
      newChildren[newChildrenTop] = newChild;
      newChildrenTop += 1;
      oldChildrenTop += 1;
    }

    // Scan the bottom of the list.
    while ((oldChildrenTop <= oldChildrenBottom) &&
        (newChildrenTop <= newChildrenBottom)) {
      final SemanticsNode oldChild = oldSemantics[oldChildrenBottom];
      final CustomPainterSemantics newChild =
          newChildSemantics[newChildrenBottom];
      if (!_canUpdateSemanticsChild(oldChild, newChild)) break;
      oldChildrenBottom -= 1;
      newChildrenBottom -= 1;
    }

    // Scan the old children in the middle of the list.
    final bool haveOldChildren = oldChildrenTop <= oldChildrenBottom;
    late final Map<Key, SemanticsNode> oldKeyedChildren;
    if (haveOldChildren) {
      oldKeyedChildren = <Key, SemanticsNode>{};
      while (oldChildrenTop <= oldChildrenBottom) {
        final SemanticsNode oldChild = oldSemantics[oldChildrenTop];
        if (oldChild.key != null) oldKeyedChildren[oldChild.key!] = oldChild;
        oldChildrenTop += 1;
      }
    }

    // Update the middle of the list.
    while (newChildrenTop <= newChildrenBottom) {
      SemanticsNode? oldChild;
      final CustomPainterSemantics newSemantics =
          newChildSemantics[newChildrenTop];
      if (haveOldChildren) {
        final Key? key = newSemantics.key;
        if (key != null) {
          oldChild = oldKeyedChildren[key];
          if (oldChild != null) {
            if (_canUpdateSemanticsChild(oldChild, newSemantics)) {
              // we found a match!
              // remove it from oldKeyedChildren so we don't unsync it later
              oldKeyedChildren.remove(key);
            } else {
              // Not a match, let's pretend we didn't see it for now.
              oldChild = null;
            }
          }
        }
      }
      assert(
          oldChild == null || _canUpdateSemanticsChild(oldChild, newSemantics));
      final SemanticsNode newChild =
          _updateSemanticsChild(oldChild, newSemantics);
      assert(oldChild == newChild || oldChild == null);
      newChildren[newChildrenTop] = newChild;
      newChildrenTop += 1;
    }

    // We've scanned the whole list.
    assert(oldChildrenTop == oldChildrenBottom + 1);
    assert(newChildrenTop == newChildrenBottom + 1);
    assert(newChildSemantics.length - newChildrenTop ==
        oldSemantics.length - oldChildrenTop);
    newChildrenBottom = newChildSemantics.length - 1;
    oldChildrenBottom = oldSemantics.length - 1;

    // Update the bottom of the list.
    while ((oldChildrenTop <= oldChildrenBottom) &&
        (newChildrenTop <= newChildrenBottom)) {
      final SemanticsNode oldChild = oldSemantics[oldChildrenTop];
      final CustomPainterSemantics newSemantics =
          newChildSemantics[newChildrenTop];
      assert(_canUpdateSemanticsChild(oldChild, newSemantics));
      final SemanticsNode newChild =
          _updateSemanticsChild(oldChild, newSemantics);
      assert(oldChild == newChild);
      newChildren[newChildrenTop] = newChild;
      newChildrenTop += 1;
      oldChildrenTop += 1;
    }

    assert(() {
      for (final SemanticsNode? node in newChildren) {
        assert(node != null);
      }
      return true;
    }());

    return newChildren.cast<SemanticsNode>();
  }

  /// Whether `oldChild` can be updated with properties from `newSemantics`.
  ///
  /// If `oldChild` can be updated, it is updated using [_updateSemanticsChild].
  /// Otherwise, the node is replaced by a new instance of [SemanticsNode].
  static bool _canUpdateSemanticsChild(
      SemanticsNode oldChild, CustomPainterSemantics newSemantics) {
    return oldChild.key == newSemantics.key;
  }

  /// Updates `oldChild` using the properties of `newSemantics`.
  ///
  /// This method requires that `_canUpdateSemanticsChild(oldChild, newSemantics)`
  /// is true prior to calling it.
  static SemanticsNode _updateSemanticsChild(
      SemanticsNode? oldChild, CustomPainterSemantics newSemantics) {
    assert(
        oldChild == null || _canUpdateSemanticsChild(oldChild, newSemantics));

    final SemanticsNode newChild = oldChild ??
        SemanticsNode(
          key: newSemantics.key,
        );

    final SemanticsProperties properties = newSemantics.properties;
    final SemanticsConfiguration config = SemanticsConfiguration();
    if (properties.sortKey != null) {
      config.sortKey = properties.sortKey;
    }
    if (properties.checked != null) {
      config.isChecked = properties.checked;
    }
    if (properties.selected != null) {
      config.isSelected = properties.selected!;
    }
    if (properties.button != null) {
      config.isButton = properties.button!;
    }
    if (properties.link != null) {
      config.isLink = properties.link!;
    }
    if (properties.textField != null) {
      config.isTextField = properties.textField!;
    }
    if (properties.slider != null) {
      config.isSlider = properties.slider!;
    }
    if (properties.keyboardKey != null) {
      config.isKeyboardKey = properties.keyboardKey!;
    }
    if (properties.readOnly != null) {
      config.isReadOnly = properties.readOnly!;
    }
    if (properties.focusable != null) {
      config.isFocusable = properties.focusable!;
    }
    if (properties.focused != null) {
      config.isFocused = properties.focused!;
    }
    if (properties.enabled != null) {
      config.isEnabled = properties.enabled;
    }
    if (properties.inMutuallyExclusiveGroup != null) {
      config.isInMutuallyExclusiveGroup = properties.inMutuallyExclusiveGroup!;
    }
    if (properties.obscured != null) {
      config.isObscured = properties.obscured!;
    }
    if (properties.multiline != null) {
      config.isMultiline = properties.multiline!;
    }
    if (properties.hidden != null) {
      config.isHidden = properties.hidden!;
    }
    if (properties.header != null) {
      config.isHeader = properties.header!;
    }
    if (properties.scopesRoute != null) {
      config.scopesRoute = properties.scopesRoute!;
    }
    if (properties.namesRoute != null) {
      config.namesRoute = properties.namesRoute!;
    }
    if (properties.liveRegion != null) {
      config.liveRegion = properties.liveRegion!;
    }
    if (properties.maxValueLength != null) {
      config.maxValueLength = properties.maxValueLength;
    }
    if (properties.currentValueLength != null) {
      config.currentValueLength = properties.currentValueLength;
    }
    if (properties.toggled != null) {
      config.isToggled = properties.toggled;
    }
    if (properties.image != null) {
      config.isImage = properties.image!;
    }
    if (properties.label != null) {
      config.label = properties.label!;
    }
    if (properties.value != null) {
      config.value = properties.value!;
    }
    if (properties.increasedValue != null) {
      config.increasedValue = properties.increasedValue!;
    }
    if (properties.decreasedValue != null) {
      config.decreasedValue = properties.decreasedValue!;
    }
    if (properties.hint != null) {
      config.hint = properties.hint!;
    }
    if (properties.textDirection != null) {
      config.textDirection = properties.textDirection;
    }
    if (properties.onTap != null) {
      config.onTap = properties.onTap;
    }
    if (properties.onLongPress != null) {
      config.onLongPress = properties.onLongPress;
    }
    if (properties.onScrollLeft != null) {
      config.onScrollLeft = properties.onScrollLeft;
    }
    if (properties.onScrollRight != null) {
      config.onScrollRight = properties.onScrollRight;
    }
    if (properties.onScrollUp != null) {
      config.onScrollUp = properties.onScrollUp;
    }
    if (properties.onScrollDown != null) {
      config.onScrollDown = properties.onScrollDown;
    }
    if (properties.onIncrease != null) {
      config.onIncrease = properties.onIncrease;
    }
    if (properties.onDecrease != null) {
      config.onDecrease = properties.onDecrease;
    }
    if (properties.onCopy != null) {
      config.onCopy = properties.onCopy;
    }
    if (properties.onCut != null) {
      config.onCut = properties.onCut;
    }
    if (properties.onPaste != null) {
      config.onPaste = properties.onPaste;
    }
    if (properties.onMoveCursorForwardByCharacter != null) {
      config.onMoveCursorForwardByCharacter =
          properties.onMoveCursorForwardByCharacter;
    }
    if (properties.onMoveCursorBackwardByCharacter != null) {
      config.onMoveCursorBackwardByCharacter =
          properties.onMoveCursorBackwardByCharacter;
    }
    if (properties.onMoveCursorForwardByWord != null) {
      config.onMoveCursorForwardByWord = properties.onMoveCursorForwardByWord;
    }
    if (properties.onMoveCursorBackwardByWord != null) {
      config.onMoveCursorBackwardByWord = properties.onMoveCursorBackwardByWord;
    }
    if (properties.onSetSelection != null) {
      config.onSetSelection = properties.onSetSelection;
    }
    if (properties.onSetText != null) {
      config.onSetText = properties.onSetText;
    }
    if (properties.onDidGainAccessibilityFocus != null) {
      config.onDidGainAccessibilityFocus =
          properties.onDidGainAccessibilityFocus;
    }
    if (properties.onDidLoseAccessibilityFocus != null) {
      config.onDidLoseAccessibilityFocus =
          properties.onDidLoseAccessibilityFocus;
    }
    if (properties.onDismiss != null) {
      config.onDismiss = properties.onDismiss;
    }

    newChild.updateWith(
      config: config,
      // As of now CustomPainter does not support multiple tree levels.
      childrenInInversePaintOrder: const <SemanticsNode>[],
    );

    newChild
      ..rect = newSemantics.rect
      ..transform = newSemantics.transform
      ..tags = newSemantics.tags;

    return newChild;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(MessageProperty('painter', '$painter'));
    properties.add(MessageProperty('foregroundPainter', '$foregroundPainter',
        level: foregroundPainter != null
            ? DiagnosticLevel.info
            : DiagnosticLevel.fine));
    properties.add(DiagnosticsProperty<Size>('preferredSize', preferredSize,
        defaultValue: Size.zero));
    properties.add(
        DiagnosticsProperty<bool>('isComplex', isComplex, defaultValue: false));
    properties.add(DiagnosticsProperty<bool>('willChange', willChange,
        defaultValue: false));
  }
}
