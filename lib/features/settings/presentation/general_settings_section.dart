import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../app/app.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../domain/settings_models.dart';

class GeneralSettingsSection extends ConsumerWidget {
  const GeneralSettingsSection({super.key, required this.storeId, required this.settings});

  final String storeId;
  final AppSettingsRecord settings;

  Future<void> _update(WidgetRef ref, AppSettingsRecord updated) async {
    await ref.read(settingsRepositoryProvider).updateSettings(updated);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settingsGeneral, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: settings.defaultLanguage,
                    decoration: InputDecoration(labelText: l10n.settingsLanguage),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'ar', child: Text('العربية')),
                      DropdownMenuItem(value: 'ckb', child: Text('کوردی')),
                    ],
                    onChanged: (value) async {
                      if (value == null) return;
                      ref.read(appLocaleProvider.notifier).state = Locale(value);
                      await _update(ref, settings.copyWith(defaultLanguage: value));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<AppThemeMode>(
                    initialValue: settings.themeMode,
                    decoration: InputDecoration(labelText: l10n.settingsTheme),
                    items: [
                      DropdownMenuItem(value: AppThemeMode.light, child: Text(l10n.settingsThemeLight)),
                      DropdownMenuItem(value: AppThemeMode.dark, child: Text(l10n.settingsThemeDark)),
                      DropdownMenuItem(value: AppThemeMode.system, child: Text(l10n.settingsThemeSystem)),
                    ],
                    onChanged: (value) async {
                      if (value == null) return;
                      ref.read(appThemeModeProvider.notifier).state = switch (value) {
                        AppThemeMode.light => ThemeMode.light,
                        AppThemeMode.dark => ThemeMode.dark,
                        AppThemeMode.system => ThemeMode.system,
                      };
                      await _update(ref, settings.copyWith(themeMode: value));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: settings.currencyCode == CurrencyInfo.usd.code
                        ? CurrencyInfo.usd.code
                        : CurrencyInfo.iqd.code,
                    decoration: InputDecoration(labelText: l10n.settingsCurrency),
                    items: [
                      DropdownMenuItem(value: CurrencyInfo.iqd.code, child: Text(l10n.currencyIqd)),
                      DropdownMenuItem(value: CurrencyInfo.usd.code, child: Text(l10n.currencyUsd)),
                    ],
                    onChanged: (value) {
                      final currency = value == CurrencyInfo.usd.code ? CurrencyInfo.usd : CurrencyInfo.iqd;
                      Money.currency = currency;
                      _update(ref, settings.copyWith(currencyCode: currency.code, currencySymbol: currency.symbol));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: settings.defaultVatRatePercent.toString(),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                    decoration: InputDecoration(labelText: context.l10n.settingsDefaultVat),
                    onFieldSubmitted: (value) =>
                        _update(ref, settings.copyWith(defaultVatRatePercent: double.tryParse(value) ?? 0)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: settings.usdExchangeRate > 0 ? settings.usdExchangeRate.toStringAsFixed(0) : '',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,4}'))],
              decoration: InputDecoration(
                labelText: l10n.settingsExchangeRate,
                helperText: l10n.settingsExchangeRateHint,
                suffixText: 'IQD / 1 USD',
              ),
              onFieldSubmitted: (value) =>
                  _update(ref, settings.copyWith(usdExchangeRate: double.tryParse(value) ?? 0)),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsKeepMargin),
              subtitle: Text(l10n.settingsKeepMarginHelp),
              value: settings.fullDiscountKeepsMargin,
              onChanged: (v) => _update(ref, settings.copyWith(fullDiscountKeepsMargin: v)),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.loyaltyTitle),
              subtitle: Text(l10n.loyaltySettingsHelp),
              value: settings.loyaltyEnabledFlag,
              onChanged: (v) => _update(ref, settings.copyWith(loyaltyEnabledFlag: v)),
            ),
            if (settings.loyaltyEnabledFlag)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: settings.loyaltySpendPerPointMinor > 0
                          ? Money.inputText(settings.loyaltySpendPerPointMinor)
                          : '',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                      decoration: InputDecoration(labelText: l10n.loyaltySpendPerPoint),
                      onFieldSubmitted: (value) => _update(
                        ref,
                        settings.copyWith(loyaltySpendPerPointMinor: Money.toMinorUnits(double.tryParse(value) ?? 0)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: settings.loyaltyPointValueMinor > 0
                          ? Money.inputText(settings.loyaltyPointValueMinor)
                          : '',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                      decoration: InputDecoration(labelText: l10n.loyaltyPointValue),
                      onFieldSubmitted: (value) => _update(
                        ref,
                        settings.copyWith(loyaltyPointValueMinor: Money.toMinorUnits(double.tryParse(value) ?? 0)),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
