import 'package:ai_pocket_tools/config.dart';
import 'package:ai_pocket_tools/shared_items/model/price_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return ListView(
      children: [
        _createTile(
          'Image Description',
          listImageDescriptionServiceProvider,
          selectedImageDescriptionServiceProvider,
        ),
        _createTile(
          'Transcription',
          listTranscriptionServiceProvider,
          selectedTranscriptionServiceProvider,
        ),
        _createTile(
          'Summarization',
          listSummarizationServiceProvider,
          selectedSummarizationServiceProvider,
        ),
        _createTile(
          'Translation',
          listTranslationServiceProvider,
          selectedTranslationServiceProvider,
        ),
        _createTile(
          'Text-to-Speech',
          listTextToSpeechServiceProvider,
          selectedTextToSpeechServiceProvider,
        ),
        _createTile(
          'Text-to-Image',
          listTextToImageServiceProvider,
          selectedTextToImageServiceProvider,
        ),
        const Divider(),
        const ExpansionTile(
          title: Text('OpenAI Configuration'),
        ),
        const ExpansionTile(
          title: Text('Ollama Configuration'),
        ),
      ],
    );
  }

  Widget _createTile<T extends PriceModel>(
    String title,
    Provider<List<T>> list,
    StateProvider<T> selected,
  ) =>
      ExpansionTile(
        title: Text(title),
        children: ref
            .watch(list)
            .map(
              (item) => RadioListTile<T>(
                value: item,
                groupValue: ref.watch(selected),
                onChanged: (selectedItem) =>
                    ref.read(selected.notifier).state = selectedItem!,
                title: Text(item.runtimeType.toString()),
                subtitle: Text(item.getUsage()),
              ),
            )
            .toList(),
      );
}
