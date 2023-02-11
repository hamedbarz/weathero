class ForecastWeatherModel {
  var _datetime;
  var _temp;
  String _main;
  String _description;
  String _icon;

  ForecastWeatherModel(
      this._datetime, this._temp, this._main, this._description, this._icon);

  String get description => _description;

  String get main => _main;

  get temp => _temp;

  get datetime => _datetime;

  get icon => _icon;
}