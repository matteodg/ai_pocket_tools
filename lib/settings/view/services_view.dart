import 'package:ai_pocket_tools/config.dart';
import 'package:ai_pocket_tools/shared_items/model/image_description.dart';
import 'package:ai_pocket_tools/shared_items/model/transcription_service.dart';
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
        const DrawerHeader(
          child: Text('Configuration'),
        ),
        ExpansionTile(
          title: const Text('Image Description'),
          children: ref
              .watch(listImageDescriptionServiceProvider)
              .map(
                (item) => RadioListTile<ImageDescriptionService>(
                  value: item,
                  groupValue:
                      ref.watch(selectedImageDescriptionServiceProvider),
                  onChanged: (selectedItem) {
                    ref
                        .read(selectedImageDescriptionServiceProvider.notifier)
                        .state = selectedItem!;
                  },
                  title: Text(item.runtimeType.toString()),
                  subtitle: Text(item.getUsage()),
                ),
              )
              .toList(),
        ),
        ExpansionTile(
          title: const Text('Transcription'),
          children: ref
              .watch(listTranscriptionServiceProvider)
              .map(
                (item) => RadioListTile<TranscriptionService>(
                  value: item,
                  groupValue: ref.watch(selectedTranscriptionServiceProvider),
                  onChanged: (selectedItem) {
                    ref
                        .read(selectedTranscriptionServiceProvider.notifier)
                        .state = selectedItem!;
                  },
                  title: Text(item.runtimeType.toString()),
                  subtitle: Text(item.getUsage()),
                ),
              )
              .toList(),
        ),
        const ExpansionTile(
          title: Text('Summarization'),
        ),
        const ExpansionTile(
          title: Text('Translation'),
        ),
        ExpansionTile(
          title: const Text('Text-to-Speech'),
          children: [
            RadioListTile(
              value: 'OpenAI',
              groupValue: 'OpenAI',
              onChanged: (str) {},
              title: const Text('OpenAI'),
              subtitle: const Text(r'$0.015 per 1K characters'),
            ),
          ],
        ),
        const ExpansionTile(
          title: Text('Text-to-Image'),
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
}
