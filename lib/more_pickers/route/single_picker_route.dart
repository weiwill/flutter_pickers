import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pickers/more_pickers/init_data.dart';
import 'package:flutter_pickers/style/picker_style.dart';

typedef void SingleCallback<T>(T data);
typedef String ResolveFunction<T>(T data);

class SinglePickerRoute<T> extends PopupRoute<T> {
  SinglePickerRoute({
    this.data,
    this.selectData,
    this.resolve,
    this.suffix,
    this.onChanged,
    this.onConfirm,
    this.theme,
    this.barrierLabel,
    this.pickerStyle,
    RouteSettings settings,
  }) : super(settings: settings);

  final T selectData;
  final dynamic data;
  ResolveFunction<T> resolve;
  final SingleCallback<T> onChanged;
  final SingleCallback<T> onConfirm;
  final ThemeData theme;

  final String suffix;
  final PickerStyle pickerStyle;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get barrierDismissible => true;

  @override
  final String barrierLabel;

  @override
  Color get barrierColor => Colors.black54;

  AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController = BottomSheet.createAnimationController(navigator.overlay);
    return _animationController;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    List<T> mData = [];
    // 初始化数据
    if (data is PickerDataType) {
      mData = pickerData[data].cast<T>();
    } else if (data is List) {
      mData.addAll(data);
    }

    Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: _PickerContentView<T>(
        data: mData,
        selectData: selectData,
        pickerStyle: pickerStyle,
        route: this,
      ),
    );
    if (theme != null) {
      bottomSheet = Theme(data: theme, child: bottomSheet);
    }

    return bottomSheet;
  }
}

class _PickerContentView<T> extends StatefulWidget {
  _PickerContentView({
    Key key,
    this.data,
    this.selectData,
    this.pickerStyle,
    @required this.route,
  }) : super(key: key);

  final List<T> data;
  final T selectData;
  final SinglePickerRoute<T> route;
  final PickerStyle pickerStyle;

  @override
  State<StatefulWidget> createState() => _PickerState<T>(this.data, this.selectData, this.pickerStyle);
}

class _PickerState<T> extends State<_PickerContentView<T>> {
  final PickerStyle _pickerStyle;
  T _selectData;
  List<T> _data = [];

  AnimationController controller;
  Animation<double> animation;

  FixedExtentScrollController scrollCtrl;

  // 单位widget Padding left
  double _laberLeft;

  _PickerState(this._data, this._selectData, this._pickerStyle) {
    _init();
  }

  @override
  void dispose() {
    scrollCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: AnimatedBuilder(
        animation: widget.route.animation,
        builder: (BuildContext context, Widget child) {
          return ClipRect(
            child: CustomSingleChildLayout(
              delegate: _BottomPickerLayout(widget.route.animation.value, pickerStyle: _pickerStyle),
              child: GestureDetector(
                child: Material(
                  color: Colors.transparent,
                  child: _renderPickerView(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _init() {
    int pindex = 0;
    pindex = _data.indexWhere((element) => element.toString() == _selectData.toString());
    // 如果没有匹配到选择器对应数据，我们得修改选择器选中数据 ，不然confirm 返回的事设置的数据
    if (pindex < 0) {
      _selectData = _data[0];
      pindex = 0;
    }

    scrollCtrl = new FixedExtentScrollController(initialItem: pindex);
    _laberLeft = _pickerLaberPadding(_data[pindex].toString());
  }

  void _setPicker(int index) {
    var selectedProvince = _data[index];

    if (_selectData.toString() != selectedProvince.toString()) {
      setState(() {
        _selectData = selectedProvince;
      });

      _notifyLocationChanged();
    }
  }

  void _notifyLocationChanged() {
    if (widget.route.onChanged != null) {
      widget.route.onChanged(_selectData);
    }
  }

  double _pickerLaberPadding(String text) {
    double left = 60;

    if (text != null) {
      left = left + text.length * 12;
    }
    return left;
  }

  double _pickerFontSize(String text) {
    if (text == null || text.length <= 6) {
      return 18.0;
    } else if (text.length < 9) {
      return 16.0;
    } else if (text.length < 13) {
      return 12.0;
    } else {
      return 10.0;
    }
  }

  Widget _renderPickerView() {
    Widget itemView = _renderItemView();

    if (!_pickerStyle.showTitleBar && _pickerStyle.menu == null) {
      return itemView;
    }
    List viewList = <Widget>[];
    if (_pickerStyle.showTitleBar) {
      viewList.add(_titleView());
    }
    if (_pickerStyle.menu != null) {
      viewList.add(_pickerStyle.menu);
    }
    viewList.add(itemView);

    return Column(children: viewList);
  }

  Widget _renderItemView() {
    // 选择器
    Widget cPicker = CupertinoPicker.builder(
      scrollController: scrollCtrl,
      itemExtent: _pickerStyle.pickerItemHeight,
      onSelectedItemChanged: (int index) {
        _setPicker(index);
        if (widget.route.suffix != null && widget.route.suffix != '') {
          // 如果设置了才计算 单位的paddingLeft
          double resuleLeft = _pickerLaberPadding(_data[index].toString());
          if (resuleLeft != _laberLeft) {
            setState(() {
              _laberLeft = resuleLeft;
            });
          }
        }
      },
      childCount: _data.length,
      itemBuilder: (_, index) {
        String text = T == String ? _data[index] : widget.route.resolve(_data[index]);
        return Align(
            alignment: Alignment.center,
            child: Text(text,
                style: TextStyle(color: _pickerStyle.textColor, fontSize: _pickerFontSize(text)),
                textAlign: TextAlign.start));
      },
    );

    Widget view;
    // 单位
    if (widget.route.suffix != null && widget.route.suffix != '') {
      Widget laberView = Center(child: AnimatedPadding(
        duration: Duration(milliseconds: 100),
        padding: EdgeInsets.only(left: _laberLeft),
        child: Text(widget.route.suffix,
            style: TextStyle(color: _pickerStyle.textColor, fontSize: 20, fontWeight: FontWeight.w500)),
      ));

      view = Stack(

          children: [cPicker, laberView]);
    } else {
      view = cPicker;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      height: _pickerStyle.pickerHeight,
      color: _pickerStyle.backgroundColor,
      child: view,
    );
  }

  // 选择器上面的view
  Widget _titleView() {
    return Container(
      height: _pickerStyle.pickerTitleHeight,
      decoration: _pickerStyle.headDecoration,
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          /// 取消按钮
          InkWell(onTap: () => Navigator.pop(context), child: _pickerStyle.cancelButton),

          /// 标题
          Expanded(child: _pickerStyle.title),

          /// 确认按钮
          InkWell(
              onTap: () {
                widget.route?.onConfirm(_selectData);
                Navigator.pop(context);
              },
              child: _pickerStyle.commitButton)
        ],
      ),
    );
  }
}

class _BottomPickerLayout extends SingleChildLayoutDelegate {
  _BottomPickerLayout(this.progress, {this.pickerStyle});

  final double progress;
  final PickerStyle pickerStyle;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    double maxHeight = pickerStyle.pickerHeight;
    if (pickerStyle.showTitleBar) {
      maxHeight += pickerStyle.pickerTitleHeight;
    }
    if (pickerStyle.menu != null) {
      maxHeight += pickerStyle.menuHeight;
    }

    return BoxConstraints(
        minWidth: constraints.maxWidth, maxWidth: constraints.maxWidth, minHeight: 0.0, maxHeight: maxHeight);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double height = size.height - childSize.height * progress;
    return Offset(0.0, height);
  }

  @override
  bool shouldRelayout(_BottomPickerLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
