import 'package:flutter/foundation.dart';
import 'package:flutter_pickers/address_picker/locations_data.dart';
import 'package:flutter_pickers/style/default_style.dart';
import 'package:flutter_pickers/style/picker_style.dart';
import 'package:flutter_pickers/time_picker/model/date_mode.dart';
import 'package:flutter_pickers/time_picker/model/pduration.dart';
import 'package:flutter_pickers/time_picker/time_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List fruits = ['apples', 'bananas', 1];
  List foods = ['apples', 'bananas' ,1];

  var a = listEquals(fruits, foods);
  print('longer >>> ${a}');
  
  // test('adds one to input values', () {
  //   Address.getCityNameByCode(provinceCode: "510000", cityCode: "510100", townCode: "510104");
  //   Address.getCityNameByCode(provinceCode: "510000", cityCode: "510100", townCode: "5104");
  //   Address.getCityNameByCode(provinceCode: "510000", cityCode: "510102");
  //   Address.getCityNameByCode(provinceCode: "510000", cityCode: "510100");
  //   Address.getCityNameByCode(provinceCode: "510000", cityCode: "5101020");
  //   Address.getCityNameByCode(provinceCode: "5100", cityCode: "5101020");
  //   Address.getCityNameByCode();
  // });

  // test('adds one to input values', () {
  //   print('longer >>> ${DateMode.MDHMS.toString()}');
  //   print('longer >>> ${DateMode.MDHMS.toString().length - 9}');
  // });

  /// 计算
  // var h = TimeUtils.calcHour();
  // var m = TimeUtils.calcMonth();
  // var d = TimeUtils.calcDay(2021,1);
  //
  // print('longer >>> $h');
  // print('longer >>> $m');
  // print('longer >>> $d');

  // var picker = DefaultPickerStyle.dark();
  // print(picker.menuHeight);

  // var m = PDuration(year: 2011);
  // print('longer2 >>> ${m.toString()}');
  // {year: 2011, month: null, day: null, hour: null, minute: null, second: null}

}
