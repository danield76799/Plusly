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
                          onChanged: (String? newValue) async {
                            if (newValue != null) {
                              final lang = newValue == 'device' ? '' : newValue;
                              await AppSettings.translationTargetLanguage.setItem(lang);
                              if (mounted) {
                                setState(() {
                                  _selectedTranslationLang = lang;
                                });
                              }
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
                      if (PlatformInfos.isMobile) ...[
                        const ListDivider(),
                        SettingsSwitchListTile.adaptive(
                          title: L10n.of(context).enableVideoNotes,
                          setting: AppSettings.enableVideoNotes,
                        ),
                      ],
                      const ListDivider(),
                      SettingsSwitchListTile.adaptive(
                        title: L10n.of(context).aiFeatures,
                        subtitle: L10n.of(context).aiFeaturesSubtitle,
                        setting: AppSettings.llmEnabled,
                      ),
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
                          'Gallery',
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.grid_view_outlined),
                        title: const Text('Columns'),
                        subtitle: Text('${AppSettings.galleryColumns.value} columns'),
                        trailing: DropdownButton<int>(
                          value: AppSettings.galleryColumns.value,
                          underline: const SizedBox(),
                          onChanged: (int? newValue) async {
                            if (newValue != null) {
                              await AppSettings.galleryColumns.setItem(newValue);
                              if (mounted) setState(() {});
                            }
                          },
                          items: const [
                            DropdownMenuItem(value: 2, child: Text('2')),
                            DropdownMenuItem(value: 3, child: Text('3')),
                            DropdownMenuItem(value: 4, child: Text('4')),
                            DropdownMenuItem(value: 5, child: Text('5')),
                            DropdownMenuItem(value: 6, child: Text('6')),
                          ],
                        ),
                      ),
                      const ListDivider(),
                      ListTile(
                        leading: const Icon(Icons.photo_size_select_large_outlined),
                        title: const Text('Thumbnail size'),
                        subtitle: Text('${AppSettings.galleryThumbnailSize.value}px'),
                        trailing: DropdownButton<int>(
                          value: AppSettings.galleryThumbnailSize.value,
                          underline: const SizedBox(),
                          onChanged: (int? newValue) async {
                            if (newValue != null) {
                              await AppSettings.galleryThumbnailSize.setItem(newValue);
                              if (mounted) setState(() {});
                            }
                          },
                          items: const [
                            DropdownMenuItem(value: 64, child: Text('64px')),
                            DropdownMenuItem(value: 96, child: Text('96px')),
                            DropdownMenuItem(value: 128, child: Text('128px')),
                            DropdownMenuItem(value: 192, child: Text('192px')),
                            DropdownMenuItem(value: 256, child: Text('256px')),
                          ],
                        ),
                      ),
                      const ListDivider(),
                      SettingsSwitchListTile.adaptive(
                        title: 'Lazy loading',
                        subtitle: 'Load images when scrolling',
                        setting: AppSettings.galleryLazyLoading,
                      ),
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
