import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/localization/app_translation.dart';
import 'language_event.dart';
import 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  static const String _languageKey = 'app_language';

  LanguageBloc() : super(const LanguageState(AppLanguage.vi)) {
    on<LoadLanguageEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_languageKey) ?? 'vi';
      final lang = AppLanguage.fromCode(code);
      AppTranslation.setLanguage(lang);
      emit(LanguageState(lang));
    });

    on<ChangeLanguageEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, event.language.code);
      AppTranslation.setLanguage(event.language);
      emit(LanguageState(event.language));
    });
  }
}
