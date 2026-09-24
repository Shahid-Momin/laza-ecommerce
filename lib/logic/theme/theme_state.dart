import 'package:equatable/equatable.dart';

class ThemeState extends Equatable {
  final bool isDark;

  const ThemeState({this.isDark = false}); // false = light (DEFAULT)

  @override
  List<Object?> get props => [isDark];
}



