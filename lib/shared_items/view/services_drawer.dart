import 'package:flutter/material.dart';

class ServicesDrawer extends StatelessWidget {
  const ServicesDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Text('Configuration'),
          ),
          ExpansionTile(
            title: const Text('Image Description'),
            children: [
              RadioListTile(
                value: 'OpenAI',
                groupValue: 'OpenAI',
                onChanged: (str) {},
                title: const Text('OpenAI'),
              ),
              RadioListTile(
                value: 'Ollama',
                groupValue: 'OpenAI',
                onChanged: (str) {},
                title: const Text('Ollama'),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('Transcription'),
            children: [
              RadioListTile(
                value: 'OpenAI',
                groupValue: 'OpenAI',
                onChanged: (str) {},
                title: const Text('OpenAI'),
                subtitle: const Text(
                  r'$0.0060 / minute (rounded to the nearest second)',
                ),
              ),
            ],
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
      ),
    );
  }
}
