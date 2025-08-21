class Environment {
  /* ATTENTION Please update your desired data. */
  static const String appName = 'OvoRide USER';
  static const String version = '1.0.0';
  static String defaultLangCode = "en";
  static String defaultLanguageName = "English";
  static const String baseCurrency = "\$";

  // LOGIN AND REG PART
  static const int otpResendSecond = 120; //OTP RESEND second
  static const String defaultCountryCode = 'US'; //Default Country Code
  static const String defaultDialCode = '1'; //Default Country Code
  static const String defaultCountry = 'United States'; //Default Country Code

  //MAP CONFIG
  static const bool addressPickerFromMapApi = true; //If true, use Google Map API for formate address picker from lat , long, else use free service reverse geocode

  static const String mapKey = "AIzaSyAo_I1ZYSkA8xxMhnvuUw1PmuiGQ6OyQcQ";
  static const double mapDefaultZoom = 16;
  static const String devToken = "\$2y\$12\$mEVBW3QASB5HMBv8igls3ejh6zw2A0Xb480HWAmYq6BY9xEifyBjG";
}
