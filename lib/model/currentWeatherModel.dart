class CurrentWeatherModel {

  String _cityName;
  var _long;
  var _lat;
  String _main;
  String _description;
  String get cityName => _cityName;
  var _temp;
  var _temp_min;
  var _temp_max;
  var _pressure;
  var _humidity;
  var _windSpeed;
  var _datetime;
  var _contry;
  var _sunrise;
  var _sunset;
  var _icon;

  CurrentWeatherModel(
      this._cityName,
      this._long,
      this._lat,
      this._main,
      this._description,
      this._temp,
      this._temp_min,
      this._temp_max,
      this._pressure,
      this._humidity,
      this._windSpeed,
      this._datetime,
      this._contry,
      this._sunrise,
      this._sunset,
      this._icon,
      );

  get long => _long;

  get lat => _lat;

  String get main => _main;

  String get description => _description;

  get temp => _temp;

  get temp_min => _temp_min;

  get temp_max => _temp_max;

  get pressure => _pressure;

  get humidity => _humidity;

  get windSpeed => _windSpeed;

  get datetime => _datetime;

  get contry => _contry;

  get sunrise => _sunrise;

  get sunset => _sunset;

  get icon => _icon;
}