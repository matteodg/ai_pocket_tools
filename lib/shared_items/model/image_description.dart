import 'package:fpdart/fpdart.dart';

mixin ImageDescriptionService {
  TaskEither<String, String> describe(String imageUrl);
}
