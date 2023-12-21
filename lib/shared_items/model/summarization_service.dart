import 'package:fpdart/fpdart.dart';

mixin SummarizationService {
  TaskEither<String, String> summarize(String text);
}
