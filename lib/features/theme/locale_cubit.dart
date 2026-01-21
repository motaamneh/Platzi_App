import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('en')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('localeCode');
    if (code != null && code.isNotEmpty) {
      emit(Locale(code));
      return;
    }

    // Fallback to device locale
    try {
      final deviceLocale = WidgetsBinding.instance.window.locale;
      if (deviceLocale.languageCode == 'ar') {
        emit(const Locale('ar'));
      } else {
        emit(const Locale('en'));
      }
    } catch (_) {
      emit(const Locale('en'));
    }
  }

  Future<void> setLocale(Locale locale) async {
    emit(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('localeCode', locale.languageCode);
  }
}
