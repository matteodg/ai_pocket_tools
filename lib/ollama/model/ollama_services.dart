import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ai_pocket_tools/shared_items/model/price_model.dart';
import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:ai_pocket_tools/shared_items/model/summarization_service.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:money2/money2.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:riverpod/riverpod.dart';

final ollamaSummarizationServiceProvider = Provider<OllamaSummarizationService>(
  (ref) => OllamaSummarizationService(),
);

class OllamaSummarizationService extends OllamaService<TextItem>
    implements SummarizationService {
  @override
  Future<Option<Money>> calculateInputCost(TextItem textItem) {
    return Future.value(
      some(
        Money.fromIntWithCurrency(0, Currency.create('USD', 2)),
      ),
    );
  }

  @override
  String getUsage() {
    return r'$0.00 / token';
  }

  @override
  TaskEither<String, String> summarize(String text) {
    return TaskEither.tryCatch(
      () async {
        const timeout = Duration(seconds: 60 * 5);

        final httpClient = HttpClient()..connectionTimeout = timeout;
        final client = OllamaClient(
          baseUrl: const String.fromEnvironment('OLLAMA_BASE_URL'),
          client: TimeoutIOClient(
            httpClient,
            timeout: timeout,
          ),
        );

        final stream = client
            .generateChatCompletionStream(
              request: GenerateChatCompletionRequest(
                model: 'llama2:latest',
                messages: [
                  const Message(
                    role: MessageRole.system,
                    content: '''
                      You are a highly skilled AI trained in language comprehension
                      and summarization. I would like you to read the following text
                      and summarize it into a concise abstract paragraph. Aim to
                      retain the most important points, providing a coherent and
                      readable summary that could help a person understand the main
                      points of the discussion without needing to read the entire
                      text. Please avoid unnecessary details or tangential points.
                      Keep the same language of the input text.
                      ''',
                  ),
                  Message(
                    role: MessageRole.user,
                    content: text,
                  ),
                ],
              ),
            )
            .timeout(timeout);

        final buf = StringBuffer();
        await for (final res in stream) {
          buf.write((res.message?.content ?? '').trim());
        }
        final response = buf.toString();

        client.endSession();

        return response;
      },
      (error, stackTrace) {
        return 'Cannot summarize: $error';
      },
    );
  }
}

abstract class OllamaService<T extends SharedItem> implements PriceModel<T> {
  @override
  String getDisplayName() {
    return 'Ollama';
  }
}

class TimeoutIOClient extends IOClient {
  TimeoutIOClient(
    super.inner, {
    this.timeout = const Duration(seconds: 30),
  });

  final Duration timeout;

  @override
  Future<Response> head(
    Uri url, {
    Map<String, String>? headers,
  }) =>
      super.head(url, headers: headers).timeout(timeout);

  @override
  Future<Uint8List> readBytes(
    Uri url, {
    Map<String, String>? headers,
  }) =>
      super.readBytes(url, headers: headers).timeout(timeout);

  @override
  Future<String> read(
    Uri url, {
    Map<String, String>? headers,
  }) =>
      super.read(url, headers: headers).timeout(timeout);

  @override
  Future<Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) =>
      super
          .delete(url, headers: headers, body: body, encoding: encoding)
          .timeout(timeout);

  @override
  Future<Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) =>
      super
          .patch(url, headers: headers, body: body, encoding: encoding)
          .timeout(timeout);

  @override
  Future<Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) =>
      super
          .put(url, headers: headers, body: body, encoding: encoding)
          .timeout(timeout);

  @override
  Future<Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) =>
      super
          .post(url, headers: headers, body: body, encoding: encoding)
          .timeout(timeout);

  @override
  Future<Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) =>
      super.get(url, headers: headers).timeout(timeout);
}
