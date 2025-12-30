import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:extera_next/utils/color_value.dart';

class ThemeBuilder extends StatefulWidget {
  final Widget Function(
    BuildContext context,
    ThemeMode themeMode,
    Color? primaryColor,
    bool pureBlack,
    bool twemoji,
  ) builder;

  final String themeModeSettingsKey;
  final String primaryColorSettingsKey;
  final String pureBlackSettingsKey;
  final String twemojiSettingsKey;

  const ThemeBuilder({
    required this.builder,
    this.themeModeSettingsKey = 'theme_mode',
    this.primaryColorSettingsKey = 'primary_color',
    this.pureBlackSettingsKey = 'pure_black',
    this.twemojiSettingsKey = 'xyz.extera.next.twemojiFont',
    super.key,
  });

  @override
  State<ThemeBuilder> createState() => ThemeController();
}

class ThemeController extends State<ThemeBuilder> {
  SharedPreferences? _sharedPreferences;
  ThemeMode? _themeMode;
  Color? _primaryColor;
  bool? _pureBlack;
  bool? _twemoji;

  ThemeMode get themeMode => _themeMode ?? ThemeMode.system;

  Color? get primaryColor => _primaryColor;

  bool get pureBlack => _pureBlack ?? false;

  bool get twemoji => _twemoji ?? false;

  static ThemeController of(BuildContext context) =>
      Provider.of<ThemeController>(
        context,
        listen: false,
      );

  void _loadData(_) async {
    final preferences =
        _sharedPreferences ??= await SharedPreferences.getInstance();

    final rawThemeMode = preferences.getString(widget.themeModeSettingsKey);
    final rawColor = preferences.getInt(widget.primaryColorSettingsKey);
    final rawPureBlack = preferences.getBool(widget.pureBlackSettingsKey);
    final rawTwemoji = preferences.getBool(widget.twemojiSettingsKey);

    setState(() {
      _themeMode = ThemeMode.values
          .singleWhereOrNull((value) => value.name == rawThemeMode);
      _primaryColor = rawColor == null ? null : Color(rawColor);
      _pureBlack = rawPureBlack;
      _twemoji = rawTwemoji;
    });
  }

  Future<void> setThemeMode(ThemeMode newThemeMode) async {
    final preferences =
        _sharedPreferences ??= await SharedPreferences.getInstance();
    await preferences.setString(widget.themeModeSettingsKey, newThemeMode.name);
    setState(() {
      _themeMode = newThemeMode;
    });
  }

  Future<void> setPrimaryColor(Color? newPrimaryColor) async {
    final preferences =
        _sharedPreferences ??= await SharedPreferences.getInstance();
    if (newPrimaryColor == null) {
      await preferences.remove(widget.primaryColorSettingsKey);
    } else {
      await preferences.setInt(
        widget.primaryColorSettingsKey,
        newPrimaryColor.hexValue,
      );
    }
    setState(() {
      _primaryColor = newPrimaryColor;
    });
  }

  Future<void> setPureBlack(bool newPureBlack) async {
    final preferences =
        _sharedPreferences ??= await SharedPreferences.getInstance();
    await preferences.setBool(widget.pureBlackSettingsKey, newPureBlack);
    setState(() {
      _pureBlack = newPureBlack;
    });
  }

  Future<void> setTwemoji(bool newTwemoji) async {
    final preferences =
        _sharedPreferences ??= await SharedPreferences.getInstance();
    await preferences.setBool(widget.twemojiSettingsKey, newTwemoji);
    setState(() {
      _twemoji = newTwemoji;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_loadData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => this,
      child: DynamicColorBuilder(
        builder: (light, _) => widget.builder(
          context,
          themeMode,
          primaryColor ?? light?.primary,
          pureBlack,
          twemoji,
        ),
      ),
    );
  }
}
