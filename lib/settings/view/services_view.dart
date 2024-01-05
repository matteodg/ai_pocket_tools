import 'package:ai_pocket_tools/config.dart';
import 'package:ai_pocket_tools/langchain/model/langchain_services.dart';
import 'package:ai_pocket_tools/settings/view/widgets/service_settings_tile.dart';
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
            ServiceSettingsTile(
              title: const Text('Image Description'),
              leading: const Icon(Icons.description),
              listProviders: listImageDescriptionServiceProvider,
              selectedProvider: selectedImageDescriptionServiceProvider,
            ),
            ServiceSettingsTile(
              title: const Text('Transcription'),
              leading: const Icon(Icons.transcribe),
              listProviders: listTranscriptionServiceProvider,
              selectedProvider: selectedTranscriptionServiceProvider,
            ),
            ServiceSettingsTile(
              title: const Text('Summarization'),
              leading: const Icon(Icons.summarize),
              listProviders: listSummarizationServiceProvider,
              selectedProvider: selectedSummarizationServiceProvider,
            ),
            ServiceSettingsTile(
              title: const Text('Translation'),
              leading: const Icon(Icons.translate),
              listProviders: listTranslationServiceProvider,
              selectedProvider: selectedTranslationServiceProvider,
            ),
            ServiceSettingsTile(
              title: const Text('Text-to-Speech'),
              leading: const Icon(Icons.volume_up),
              listProviders: listTextToSpeechServiceProvider,
              selectedProvider: selectedTextToSpeechServiceProvider,
            ),
            ServiceSettingsTile(
              title: const Text('Text-to-Image'),
              leading: const Icon(Icons.image),
              listProviders: listTextToImageServiceProvider,
              selectedProvider: selectedTextToImageServiceProvider,
            ),
            ServiceSettingsTile(
              title: const Text('Chat'),
              leading: const Icon(Icons.chat),
              listProviders: listChatServiceProvider,
              selectedProvider: selectedChatServiceProvider,
            ),
          ],
        ),
        SettingsSection(
          title: const Text('LangChain'),
          tiles: <SettingsTile>[
            ServiceSettingsTile(
              title: const Text('LanguageModel'),
              leading: const Icon(Icons.chat),
              listProviders: listBaseLanguageModelProvider,
              selectedProvider: selectedBaseLanguageModelProvider,
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
}
