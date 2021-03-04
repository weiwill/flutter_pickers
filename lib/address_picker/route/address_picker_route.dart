import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pickers/address_picker/model/Address.dart';
import 'package:flutter_pickers/style/picker_style.dart';

import '../locations_data.dart';

typedef AddressCallback(Address address);

/// 自定义 地区选择器
/// * [initAddress] 初始化 地址
/// * [limitAdcode] 只显示传入的 adcode的省市区内容   默认null则全部显示
/// * [onChanged]   选择器发生变动
/// * [onConfirm]   选择器提交
/// * [addAllItem] 市、区是否添加 '全部' 选项     默认：true
class AddressPickerRoute<T> extends PopupRoute<T> {
  AddressPickerRoute({
    this.addAllItem,
    this.pickerStyle,
    this.initAddress,
    this.limitAdcode,
    this.onChanged,
    this.onConfirm,
    this.theme,
    this.barrierLabel,
    RouteSettings settings,
  }) : super(settings: settings);

  final Address initAddress;
  final Set<String> limitAdcode;
  final AddressCallback onChanged;
  final AddressCallback onConfirm;
  final ThemeData theme;
  final bool addAllItem;

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
    _animationController =
        BottomSheet.createAnimationController(navigator.overlay);
    return _animationController;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: _PickerContentView(
        initAddress: initAddress,
        addAllItem: addAllItem,
        pickerStyle: pickerStyle,
        limitAdcode: limitAdcode,
        route: this,
      ),
    );
    if (theme != null) {
      bottomSheet = Theme(data: theme, child: bottomSheet);
    }

    return bottomSheet;
  }
}

class _PickerContentView extends StatefulWidget {
  _PickerContentView({
    Key key,
    this.initAddress,
    this.pickerStyle,
    this.addAllItem,
    this.limitAdcode,
    @required this.route,
  }) : super(key: key);

  final Address initAddress;
  final AddressPickerRoute route;
  final bool addAllItem;
  final Set<String> limitAdcode;
  final PickerStyle pickerStyle;

  @override
  State<StatefulWidget> createState() => _PickerState(
      this.initAddress,
      this.addAllItem,
      this.limitAdcode,
      this.pickerStyle);
}

class _PickerState extends State<_PickerContentView> {
  final PickerStyle _pickerStyle;

  Address _address;
  List<MapEntry<String, String>> cities = [];
  List<MapEntry<String, String>> towns = [];
  List<MapEntry<String, String>> provinces = [];

  // 是否显示县级
  bool hasTown = true;

  AddressService addressService;

  // 是否添加全部
  final bool addAllItem;

  final Set<String> limitAdcode;

  AnimationController controller;
  Animation<double> animation;

  FixedExtentScrollController provinceScrollCtrl,
      cityScrollCtrl,
      townScrollCtrl;

  _PickerState(
      this._address,
      this.addAllItem,
      this.limitAdcode,
      this._pickerStyle) {
    _init();
  }

  @override
  void dispose() {
    provinceScrollCtrl.dispose();
    cityScrollCtrl.dispose();
    townScrollCtrl?.dispose();

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
              delegate: _BottomPickerLayout(
                  widget.route.animation.value, this._pickerStyle),
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
    addressService = AddressService(addAllItem: addAllItem, limitAdcode: limitAdcode);
    if (_address == null) {
      _address = Address('','','');
    }
    provinces = addressService.provinces;
    hasTown = _address?.townCode != null;
    int pindex = 0;
    int cindex = 0;
    int tindex = 0;
    pindex = provinces.indexWhere((p) => p.key == _address.provinceCode);
    // pindex = provinces.indexWhere((p) => p == _currentProvince);
    pindex = pindex >= 0 ? pindex : 0;
    MapEntry<String, String> selectedProvince = provinces.length > 0 ? provinces[pindex]: null;
    if (selectedProvince != null) {
      // _currentProvince = selectedProvince;
      _address.provinceCode = selectedProvince.key;
      _address.provinceName = selectedProvince.value;
      cities = addressService.getCities(selectedProvince);

      cindex = cities.indexWhere((c) => c.key == _address.cityCode);
      cindex = cindex >= 0 ? cindex : 0;
      MapEntry<String, String> _currentCity = cities.length > 0 ? cities[cindex] : null;
      if (_currentCity != null) {
        _address.cityCode = _currentCity.key;
        _address.cityName = _currentCity.value;
        // print('longer >>> 外面接到的$cities');

        if (hasTown) {
          towns = addressService.getTowns(cities[cindex]);
          tindex = towns.indexWhere((t) => t.key == _address.townCode);
          tindex = tindex >= 0 ? tindex : 0;
          if (towns.length == 0) {
            _address.townCode = '';
            _address.townName = '';
          } else {
            _address.townCode = towns[tindex].key;
            _address.townName = towns[tindex].value;
          }
        }
      }



    }

    provinceScrollCtrl = new FixedExtentScrollController(initialItem: pindex);
    cityScrollCtrl = new FixedExtentScrollController(initialItem: cindex);
    townScrollCtrl = new FixedExtentScrollController(initialItem: tindex);
  }

  void _setProvince(int index) {
    MapEntry<String, String> selectedProvince = provinces[index];
    // print('longer >>> index:$index  _currentProvince:$_currentProvince selectedProvince:$selectedProvince ');
    if (_address.provinceCode != selectedProvince.key) {
      setState(() {
        _address.provinceCode = selectedProvince.key;
        _address.provinceName = selectedProvince.value;

        cities = addressService.getCities(selectedProvince);
        // print('longer >>> 返回的城市数据：$cities');
        if (cities.length > 0) {
          _address.cityCode = cities[0].key;
          _address.cityName = cities[0].value;
          cityScrollCtrl.jumpToItem(1);
          cityScrollCtrl.jumpToItem(0);
          if (hasTown) {
            towns = addressService.getTowns(cities[0]);
            // _currentTown = towns[0];
            if (towns.length > 0) {
              _address.townCode = towns[0].key;
              _address.townName = towns[0].value;
              townScrollCtrl.jumpToItem(1);
              townScrollCtrl.jumpToItem(0);
            }
          }
        }
      });

      _notifyLocationChanged();
    }
  }

  void _setCity(int index) {
    index = cities.length > index ? index : 0;
    MapEntry<String, String> selectedCity = cities[index];
    if (_address.cityCode != selectedCity.key) {
      setState(() {
        _address.cityCode = selectedCity.key;
        _address.cityName = selectedCity.value;
        if (hasTown) {
          towns = addressService.getTowns(cities[index]);
          if (towns != null && towns.length > 0) {
            _address.townCode = towns[0].key;
            _address.townName = towns[0].value;
          } else {
            _address.townCode = '';
            _address.townName = '';
          }
          townScrollCtrl.jumpToItem(1);
          townScrollCtrl.jumpToItem(0);
        }
      });

      _notifyLocationChanged();
    }
  }

  void _setTown(int index) {
    index = towns.length > index ? index : 0;
    MapEntry<String, String> selectedTown = towns[index];
    if (_address.townCode != selectedTown.key) {
      _address.townCode = selectedTown.key;
      _address.townName = selectedTown.value;
      _notifyLocationChanged();
    }
  }

  void _notifyLocationChanged() {
    if (widget.route.onChanged != null) {
      widget.route.onChanged(_address);
    }
  }

  double _pickerFontSize(String text) {
    double ratio = hasTown ? 0.0 : 2.0;
    if (text == null || text.length <= 6) {
      return 18.0;
    } else if (text.length < 9) {
      return 16.0 + ratio;
    } else if (text.length < 13) {
      return 12.0 + ratio;
    } else {
      return 10.0 + ratio;
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
    return Container(
      height: _pickerStyle.pickerHeight,
      color: _pickerStyle.backgroundColor,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoPicker.builder(
                scrollController: provinceScrollCtrl,
                itemExtent: _pickerStyle.pickerItemHeight,
                onSelectedItemChanged: (int index) {
                  _setProvince(index);
                },
                childCount: provinces.length,
                itemBuilder: (_, index) {
                  String text = provinces[index].value;
                  return Align(
                      alignment: Alignment.center,
                      child: Text(text,
                          style: TextStyle(
                              color: _pickerStyle.textColor,
                              fontSize: _pickerFontSize(text)),
                          textAlign: TextAlign.start));
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
                padding: EdgeInsets.all(8.0),
                child: CupertinoPicker.builder(
                  scrollController: cityScrollCtrl,
                  itemExtent: _pickerStyle.pickerItemHeight,
                  onSelectedItemChanged: (int index) {
                    _setCity(index);
                  },
                  childCount: cities.length,
                  itemBuilder: (_, index) {
                    String text = cities[index].value;
                    return Align(
                      alignment: Alignment.center,
                      child: Text('$text',
                          style: TextStyle(
                              color: _pickerStyle.textColor,
                              fontSize: _pickerFontSize(text)),
                          textAlign: TextAlign.start),
                    );
                  },
                )),
          ),
          hasTown
              ? Expanded(
                  child: Container(
                      padding: EdgeInsets.all(8.0),
                      child: CupertinoPicker.builder(
                        scrollController: townScrollCtrl,
                        itemExtent: _pickerStyle.pickerItemHeight,
                        onSelectedItemChanged: (int index) {
                          _setTown(index);
                        },
                        childCount: towns.length,
                        itemBuilder: (_, index) {
                          String text = towns[index].value;
                          return Align(
                            alignment: Alignment.center,
                            child: Text(text,
                                style: TextStyle(
                                    color: _pickerStyle.textColor,
                                    fontSize: _pickerFontSize(text)),
                                textAlign: TextAlign.start),
                          );
                        },
                      )),
                )
              : SizedBox()
        ],
      ),
    );
  }

  // 选择器上面的view
  Widget _titleView() {
    return Container(
      height: _pickerStyle.pickerTitleHeight,
      decoration: _pickerStyle.headDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          /// 取消按钮
          InkWell(
              onTap: () => Navigator.pop(context),
              child: _pickerStyle.cancelButton),

          /// 标题
          Expanded(child: _pickerStyle.title),

          /// 确认按钮
          InkWell(
              onTap: () {
                widget.route?.onConfirm(_address);
                Navigator.pop(context);
              },
              child: _pickerStyle.commitButton)
        ],
      ),
    );
  }
}

class _BottomPickerLayout extends SingleChildLayoutDelegate {
  _BottomPickerLayout(this.progress, this.pickerStyle);

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
        minWidth: constraints.maxWidth,
        maxWidth: constraints.maxWidth,
        minHeight: 0.0,
        maxHeight: maxHeight);
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
