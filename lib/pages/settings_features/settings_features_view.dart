import 'package:flutter/material.dart';

import 'package:Pulsly/config/app_config.dart';
import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/config/themes.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/widgets/layouts/max_width_body.dart';
import 'package:Pulsly/widgets/list_divider.dart';
import 'package:Pulsly/widgets/settings_switch_list_tile.dart';
import 'settings_features.dart';

class SettingsFeaturesView extends StatefulWidget {
  final SettingsFeaturesController controller;
  const SettingsFeaturesView(this.controller, {super.key});

  @override
  State<SettingsFeaturesView> createState() => _SettingsFeaturesViewState();
}

class _SettingsFeaturesViewState extends State<SettingsFeaturesView> {
  String _selectedTranslationLang = '';

  @override
  void initState() {
    super.initState();
    _selectedTranslationLang = AppSettings.translationTargetLanguage.value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(AppConfig.borderRadius);

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context).featureSwitches),
        automaticallyImplyLeading: !FluffyThemes.isColumnMode(context),
        centerTitle: FluffyThemes.isColumnMode(context),
      ),
      body: ListTileTheme(
        iconColor: theme.textTheme.bodyLarge!.color,
        child: MaxWidthBody(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Material(
                  clipBehavior: Clip.hardEdge,
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: borderRadius,
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          L10n.of(context).featureSwitches,
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SettingsSwitchListTile.adaptive(
                        title: L10n.of(context).useLegacyAppBar,
                        setting: AppSettings.useLegacyChatListAppBar,
                      ),
                      const ListDivider(),
                      SettingsSwitchListTile.adaptive(
                        title: L10n.of(context).useLegacyNavBar,
                        setting: AppSettings.useLegacyNavBar,
                      ),
                      const ListDivider(),
                      SettingsSwitchListTile.adaptive(
                        title: L10n.of(context).messageTranslations,
                        setting: AppSettings.messageTranslation,
                      ),
                      const ListDivider(),
                      ListTile(
                        leading: const Icon(Icons.translate_outlined),
                        title: const Text('Translation language'),
                        subtitle: Text(
                          _selectedTranslationLang.isEmpty
                              ? 'Device language'
                              : _selectedTranslationLang.toUpperCase(),
                        ),
                        trailing: DropdownButton<String>(
                          value: _selectedTranslationLang.isEmpty
                              ? 'device'
                              : _selectedTranslationLang,
                          underline: const SizedBox(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              final lang = newValue == 'device' ? '' : newValue;
                              AppSettings.translationTargetLanguage.setItem(lang);
                              setState(() {
                                _selectedTranslationLang = lang;
                              });
                            }
                          },
                          items: const [
                            DropdownMenuItem(value: 'device', child: Text('Device')),
                            DropdownMenuItem(value: 'en', child: Text('EN')),
                            DropdownMenuItem(value: 'nl', child: Text('NL')),
                            DropdownMenuItem(value: 'de', child: Text('DE')),
                            DropdownMenuItem(value: 'fr', child: Text('FR')),
                            DropdownMenuItem(value: 'es', child: Text('ES')),
                            DropdownMenuItem(value: 'it', child: Text('IT')),
                            DropdownMenuItem(value: 'pt', child: Text('PT')),
                            DropdownMenuItem(value: 'ru', child: Text('RU')),
                            DropdownMenuItem(value: 'zh', child: Text('ZH')),
                            DropdownMenuItem(value: 'ja', child: Text('JA')),
                            DropdownMenuItem(value: 'ko', child: Text('KO')),
                          ],
                        ),
                      ),
                      const ListDivider(),
                      SettingsSwitchListTile.adaptive(
                        title: L10n.of(context).latexMath,
                        setting: AppSettings.latexMath,
                      ),
                      const ListDivider(),
                      SettingsSwitchListTile.adaptive(
                        title: L10n.of(context).jitsiFeatureFlag,
                        setting: AppSettings.experimentalJitsi,
                      ),
                      const ListDivider(),
                      SettingsSwitchListTile.adaptive(
                        title: L10n.of(context).enableAppBarCenterTitle,
                        setting: AppSettings.enableAppBarCenterTitle,
                      ),
                      const ListDivider(),
                      SettingsSwitchListTile.adaptive(
                        title: L10n.of(context).enablePeopleTab,
                        setting: AppSettings.enablePeopleTab,
                      ),
                      if (PlatformInfos.isMobile) ...[
                        const ListDivider(),
                        SettingsSwitchListTile.adaptive(
                          title: L10n.of(context).enableVideoNotes,
                          setting: AppSettings.enableVideoNotes,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Material(
                  clipBehavior: Clip.hardEdge,
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: borderRadius,
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          'Backup & Restore',
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.download_outlined),
                        title: const Text('Export settings'),
                        subtitle: const Text(
                          'Save to app folder and share to Downloads/Drive',
                        ),
                        onTap: widget.controller.exportSettings,
                      ),
                      const ListDivider(),
                      ListTile(
                        leading: const Icon(Icons.restore_outlined),
                        title: const Text('Restore settings'),
                        subtitle: const Text(
                          'Load preferences from a JSON file',
                        ),
                        onTap: widget.controller.restoreSettings,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
