import 'package:equatable/equatable.dart';
import '../../core/localization/app_translation.dart';

class LanguageState extends Equatable {
  final AppLanguage language;

  const LanguageState(this.language);

  @override
  List<Object?> get props => [language];
}
