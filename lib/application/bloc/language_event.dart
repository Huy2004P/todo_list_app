import '../../core/localization/app_translation.dart';

abstract class LanguageEvent {}

class LoadLanguageEvent extends LanguageEvent {}

class ChangeLanguageEvent extends LanguageEvent {
  final AppLanguage language;
  ChangeLanguageEvent(this.language);
}
