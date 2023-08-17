import 'package:bookingmanager/core/services/localization/locale_keys.g.dart';
import 'package:bookingmanager/product/constants/app_constants.dart';
import 'package:bookingmanager/view/settings/settings_notifier.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  final languageKey = const Key("languageKey");

  final provider = ChangeNotifierProvider((ref) => SettingsNotifier());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.settings_title.tr())),
      body: _body(),
    );
  }

  Widget _body() {
    return ListView(
      children: [_language()],
    );
  }

  Widget _language() {
    return ListTile(
      onTap: () => showModalBottomSheet(
          context: context, builder: (context) => _languageBottomSheet()),
      title: Text(LocaleKeys.settings_language.tr()),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppConstants.languageCodes[ref.read(provider).languageCode]!),
          const SizedBox(width: 8),
          AppConstants.languageImages[ref.watch(provider).languageCode]!
              .assetImage(width: 32)
        ],
      ),
    );
  }

  Widget _languageBottomSheet() {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _languageTile("en"),
          _languageTile("tr"),
          _languageTile("cs"),
        ],
      ),
    );
  }

  Widget _languageTile(String languageCode) {
    return ListTile(
      title: Text(AppConstants.languageCodes[languageCode]!),
      onTap: () {
        ref.read(provider).setLanguage(languageCode, context);
        Navigator.pop(context);
      },
      trailing:
          AppConstants.languageImages[languageCode]!.assetImage(width: 32),
    );
  }
}
