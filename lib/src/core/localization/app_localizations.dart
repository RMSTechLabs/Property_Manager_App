import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations._(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('ar'),
  ];

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString(
      'lib/src/core/localization/app_${locale.languageCode}.arb',
    );
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Common strings
  String get appTitle => translate('app_title');
  String get login => translate('login');
  String get signIn => translate('Sign In');
  String get logout => translate('logout');
  String get email => translate('email');
  String get password => translate('password');
  String get forgotPassword => translate('forgot_password');
  String get rememberMe => translate('remember_me');
  String get welcome => translate('welcome');
  String get properties => translate('properties');
  String get tenants => translate('tenants');
  String get maintenance => translate('maintenance');
  String get reports => translate('reports');
  String get settings => translate('settings');
  String get profile => translate('profile');
  String get notifications => translate('notifications');
  String get addProperty => translate('add_property');
  String get propertyDetails => translate('property_details');
  String get address => translate('address');
  String get rent => translate('rent');
  String get status => translate('status');
  String get available => translate('available');
  String get occupied => translate('occupied');
  String get maintenance_required => translate('maintenance_required');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get search => translate('search');
  String get filter => translate('filter');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get retry => translate('retry');
  String get noDataFound => translate('no data found');
  String get internetConnectionError => translate('internet connection error');
  String get serverError => translate('server error');
  String get invalidCredentials => translate('invalid credentials');
  String get invalidEmail => translate('invalid email');
  String get invalidPassword => translate('invalid password');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations._(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
