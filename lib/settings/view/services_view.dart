import 'package:ai_pocket_tools/config.dart';
import 'package:ai_pocket_tools/shared_items/model/price_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';

class ServicesView extends ConsumerStatefulWidget {
  const ServicesView({
    super.key,
  });

  @override
  ConsumerState<ServicesView> createState() => _ServicesViewState();
}

class _ServicesViewState extends ConsumerState<ServicesView> {
  @override
  Widget build(BuildContext context) {
    return SettingsList(
      sections: [
        SettingsSection(
          title: const Text('Services'),
          tiles: <SettingsTile>[
            _createTile(
              'Image Description',
              const Icon(Icons.description),
              listImageDescriptionServiceProvider,
              selectedImageDescriptionServiceProvider,
            ),
            _createTile(
              'Transcription',
              const Icon(Icons.transcribe),
              listTranscriptionServiceProvider,
              selectedTranscriptionServiceProvider,
            ),
            _createTile(
              'Summarization',
              const Icon(Icons.summarize),
              listSummarizationServiceProvider,
              selectedSummarizationServiceProvider,
            ),
            _createTile(
              'Translation',
              const Icon(Icons.translate),
              listTranslationServiceProvider,
              selectedTranslationServiceProvider,
            ),
            _createTile(
              'Text-to-Speech',
              const Icon(Icons.volume_up),
              listTextToSpeechServiceProvider,
              selectedTextToSpeechServiceProvider,
            ),
            _createTile(
              'Text-to-Image',
              const Icon(Icons.image),
              listTextToImageServiceProvider,
              selectedTextToImageServiceProvider,
            ),
          ],
        ),
        SettingsSection(
          title: const Text('Providers'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              title: const Text('OpenAI Configuration'),
            ),
            SettingsTile.navigation(
              title: const Text('Ollama Configuration'),
            ),
          ],
        ),
      ],
    );
  }

  SettingsTile _createTile<T extends PriceModel>(
    String title,
    Icon icon,
    Provider<List<T>> list,
    StateProvider<T> selected,
  ) {
    return SettingsTile.navigation(
      title: Text(title),
      leading: icon,
      description: Text(
        ref.watch(selected).getDisplayName(),
      ),
      onPressed: (context) {
        return showModalBottomSheet<ListView>(
          context: context,
          builder: (context) {
            return Column(
              children: [
                const SizedBox(height: 10),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const Divider(),
                Expanded(
                  child: ListView(
                    children: ref
                        .watch(list)
                        .map(
                          (item) => RadioListTile<T>(
                            value: item,
                            groupValue: ref.watch(selected),
                            onChanged: (selectedItem) => ref
                                .read(selected.notifier)
                                .state = selectedItem!,
                            title: Text(item.getDisplayName()),
                            subtitle: Text(item.getUsage()),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
