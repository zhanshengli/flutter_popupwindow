## 介绍
一个带三角形指示器的、可上下左右显示的popwindow
## 特性
PopWindow需要一个设置GlobleKey的锚点组件才能正确的显示；当显示在锚点左右两边时，对PopWindow的高度
做了限制，最高是280像素;当显示在锚点上下时，PopWindow的宽度默认是锚点的宽度，可以手动设置width

## 屏幕截图
 ![image](https://github.com/zhanshengli/flutter_popupwindow/blob/main/screenshot/left.jpg)
![image](https://github.com/zhanshengli/flutter_popupwindow/blob/main/screenshot/top.jpg)
![image](https://github.com/zhanshengli/flutter_popupwindow/blob/main/screenshot/right.jpg)
![image](https://github.com/zhanshengli/flutter_popupwindow/blob/main/screenshot/bottom.jpg)


##  如何使用

```dart
GlobalKey globalKey = GlobalKey();
TextButton(
key: globalKey,
onPressed: () {
showPopWindow(globalKey, context,
location: PopLocation.bottom,///popwindow显示在锚点位置（上下左右）
showBarrer: true,///是否显示遮罩
showAnchor: true,///是否显示三角形指示器
width: 200,///popwindow宽度
height: 200,///popwindow高度
space: 10,///popwindow与锚点之间的间距
(context, animation, secondaryAnimation) {
return Text("测试");
});
},
child: Text("PopupWindow"),
)
```

