import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';

class RagPage extends ConsumerStatefulWidget {
  const RagPage({super.key});

  @override
  ConsumerState<RagPage> createState() => _RagPageState();
}

class _RagPageState extends ConsumerState<RagPage> {
  final urlController = TextEditingController(
    text: 'https://en.wikipedia.org/wiki/Oppenheimer_(film)',
  );
  final chunkSizeController = TextEditingController(text: '2000');
  final chunkOverlapController = TextEditingController(text: '200');
  var _count = 0;
  final queryController = TextEditingController(
    text: 'Create a table with two columns: actors and '
        'their respective characters played in Oppenheimer.',
  );
  bool _keepSeparator = true;
  final vectorStore = MemoryVectorStore(
    embeddings: OpenAIEmbeddings(
      apiKey: const String.fromEnvironment('OPENAI_API_KEY'),
    ),
  );
  String _text = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retrieval Augmented Generation'),
      ),
      body: Column(
        children: [
          TextField(
            controller: urlController,
            decoration: const InputDecoration(
              labelText: 'URL',
              contentPadding: EdgeInsets.all(8),
            ),
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
          TextField(
            controller: chunkSizeController,
            decoration: const InputDecoration(
              labelText: 'Chunk Size',
              contentPadding: EdgeInsets.all(8),
            ),
          ),
          TextField(
            controller: chunkOverlapController,
            decoration: const InputDecoration(
              labelText: 'Chunk Overlap',
              contentPadding: EdgeInsets.all(8),
            ),
          ),
          Row(
            children: [
              Checkbox(
                value: _keepSeparator,
                onChanged: (value) {
                  setState(() {
                    _keepSeparator = value ?? true;
                  });
                },
              ),
              const Text('Keep Separator'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final loader = WebBaseLoader([
                    urlController.text,
                  ]);
                  final documents = await loader.load();
                  final textSplitter = RecursiveCharacterTextSplitter(
                    chunkSize: int.parse(chunkSizeController.text),
                    chunkOverlap: int.parse(chunkOverlapController.text),
                    keepSeparator: _keepSeparator,
                  );
                  final textsWithSources = textSplitter
                      .splitDocuments(documents)
                      .mapWithIndex(
                        (doc, i) => doc.copyWith(
                          metadata: {
                            ...doc.metadata,
                            'source': '$i-pl',
                          },
                        ),
                      )
                      .toList(growable: false);
                  await vectorStore.addDocuments(
                    documents: textsWithSources,
                  );
                  setState(() {
                    _count = textsWithSources.length;
                  });
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Indexed ${textsWithSources.length} documents',
                      ),
                    ),
                  );
                },
                child: const Text('Index document'),
              ),
              ElevatedButton(
                onPressed: () async {
                  vectorStore.memoryVectors.clear();
                  setState(() {
                    _count = vectorStore.memoryVectors.length;
                  });
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Cleared store',
                      ),
                    ),
                  );
                },
                child: const Text('Clear Store'),
              ),
              Text('$_count'),
            ],
          ),
          TextField(
            controller: queryController,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: 'Query',
              contentPadding: EdgeInsets.all(8),
            ),
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // final selected = ref.watch(selectedBaseLanguageModelProvider);
              // final openai = ref.read(openaiBaseLanguageModelProvider);
              // final ollama = ref.read(ollamaBaseLanguageModelProvider);

              final query = queryController.text;
              var response;
              // if (selected == openai) {
              final llm = ChatOpenAI(
                apiKey: const String.fromEnvironment('OPENAI_API_KEY'),
                defaultOptions: const ChatOpenAIOptions(
                  // temperature: 0,
                  functions: [],
                ),
              );
              final qaChain = OpenAIQAWithSourcesChain(llm: llm);
              final docPrompt = PromptTemplate.fromTemplate(
                'Content: {page_content}\nSource: {source}',
              );
              final finalQAChain = StuffDocumentsChain(
                llmChain: qaChain,
                documentPrompt: docPrompt,
              );
              final retrievalQA = RetrievalQAChain(
                retriever: vectorStore.asRetriever(),
                combineDocumentsChain: finalQAChain,
              );
              response = await retrievalQA(query);
              // } else if (selected == ollama) {
              //   final llm = ChatOllama(
              //     baseUrl: const String.fromEnvironment('OLLAMA_BASE_URL'),
              //     defaultOptions: const ChatOllamaOptions(
              //       model: 'llama2:latest',
              //     ),
              //   );
              //   final qaChain = ConversationChain(llm: llm);
              //   final finalQAChain = StuffDocumentsChain(
              //     llmChain: qaChain,
              //   );
              //   final retrievalQA = RetrievalQAChain(
              //     retriever: vectorStore.asRetriever(),
              //     combineDocumentsChain: finalQAChain,
              //   );
              //   response = await retrievalQA(query);
              // } else {
              //   throw UnimplementedError();
              // }

              setState(() {
                _text = response['result'].toString();
              });
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Executed query',
                  ),
                ),
              );
            },
            child: const Text('Execute Query'),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: MarkdownBody(
                  selectable: true,
                  data: _text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
