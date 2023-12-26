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
          ListTile(
            title: const Text('Image Description'),
            onTap: () {},
          ),
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
          ListTile(
            title: const Text('Transcription'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Summarization'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Translation'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Text-to-speech'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Text-to-image'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
