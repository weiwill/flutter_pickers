import '../locations_data.dart';

class Address {
  String provinceCode;
  String provinceName;
  String cityCode;
  String cityName;
  String townCode;
  String townName;

  // Address(
  //     this.provinceCode,
  //     this.provinceName,
  //     this.cityCode,
  //     this.cityName,
  //     this.townCode,
  //     this.townName);
  Address._(this.provinceCode, this.provinceName, this.cityCode, this.cityName,
      this.townCode, this.townName);

  factory Address(String provinceName, String cityName, String townName) {
    List<String> cityCode = AddressService.getCityCodeByName(
        initialProvinceName: provinceName,
        initialCityName: cityName,
        initialTownName: townName);
    return Address._(cityCode[0] ?? '', provinceName, cityCode[1] ?? '', cityName,
        cityCode[2] ?? '', townName);
  }

  Address.fromJson(Map<String, String> json)
      : provinceCode = json['code'],
        provinceName = json['provinceName'],
        cityCode = json['cityCode'],
        cityName = json['cityName'],
        townCode = json['townCode'],
        townName = json['townName'];

  Map<String, String> toJson() => <String, String>{
        'provinceCode': provinceCode,
        'provinceName': provinceName,
        'cityCode': cityCode,
        'cityName': cityName,
        'townCode': townCode,
        'townName': townName,
      };
}
