import 'package:ai_pocket_tools/shared_items/model/price_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';

class ServiceSettingsTile<T extends PriceModel> extends SettingsTile {
  ServiceSettingsTile({
    required super.title,
    required super.leading,
    required this.listProviders,
    required this.selectedProvider,
    super.key,
  });

  final Provider<List<T>> listProviders;
  final StateProvider<T> selectedProvider;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final selected = ref.watch(selectedProvider);
        final list = ref.watch(listProviders);
        return SettingsTile.navigation(
          title: super.title,
          leading: super.leading,
          description: Text(
            selected.getDisplayName(),
          ),
          onPressed: (context) {
            return showModalBottomSheet<ListView>(
              context: context,
              builder: (context) {
                return Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      (super.title as Text).data!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView(
                        children: list.map(
                          (item) {
                            return RadioListTile<T>(
                              value: item,
                              groupValue: selected,
                              onChanged: (selectedItem) {
                                ref.read(selectedProvider.notifier).state =
                                    selectedItem!;
                                Navigator.pop(context);
                              },
                              title: Text(item.getDisplayName()),
                              subtitle: Text(item.getUsage()),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
