abstract class ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}

class LoadThemeEvent extends ThemeEvent {}

class ChangeTextScaleEvent extends ThemeEvent {
  final double textScaleFactor;
  ChangeTextScaleEvent(this.textScaleFactor);
}
