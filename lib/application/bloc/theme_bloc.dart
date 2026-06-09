import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'theme_mode';
  static const String _scaleKey = 'text_scale_factor';

  ThemeBloc() : super(const ThemeState(ThemeMode.light, textScaleFactor: 1.0)) {
    on<LoadThemeEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey) ?? false;
      final scale = prefs.getDouble(_scaleKey) ?? 1.0;
      emit(ThemeState(
        isDark ? ThemeMode.dark : ThemeMode.light,
        textScaleFactor: scale,
      ));
    });

    on<ToggleThemeEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final isDark = state.themeMode == ThemeMode.dark;
      final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
      await prefs.setBool(_themeKey, !isDark);
      emit(ThemeState(
        newMode,
        textScaleFactor: state.textScaleFactor,
      ));
    });

    on<ChangeTextScaleEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_scaleKey, event.textScaleFactor);
      emit(ThemeState(
        state.themeMode,
        textScaleFactor: event.textScaleFactor,
      ));
    });
  }
}
