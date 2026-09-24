import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _keyThemeDark = 'theme_dark';

  ThemeBloc() : super(const ThemeState(isDark: false)) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
    on<SetTheme>(_onSetTheme);

    add(const LoadTheme());
  }

  Future<void> _onLoadTheme(
      LoadTheme event,
      Emitter<ThemeState> emit,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_keyThemeDark) ?? false;
    emit(ThemeState(isDark: isDark));
  }

  Future<void> _onToggleTheme(
      ToggleTheme event,
      Emitter<ThemeState> emit,
      ) async {
    final newValue = !state.isDark;
    await _persist(newValue);
    emit(ThemeState(isDark: newValue));
  }

  Future<void> _onSetTheme(
      SetTheme event,
      Emitter<ThemeState> emit,
      ) async {
    await _persist(event.isDark);
    emit(ThemeState(isDark: event.isDark));
  }

  Future<void> _persist(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyThemeDark, isDark);
  }
}