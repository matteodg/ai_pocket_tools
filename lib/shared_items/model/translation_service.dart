import 'package:fpdart/fpdart.dart';

mixin TranslationService {
  TaskEither<String, String> translate(String text, String language);
}
