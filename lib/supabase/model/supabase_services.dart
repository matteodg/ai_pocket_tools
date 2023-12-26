import 'dart:io';

import 'package:ai_pocket_tools/shared_items/model/remote_storage_service.dart';
import 'package:fpdart/fpdart.dart';
import 'package:path/path.dart';
import 'package:riverpod/riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final remoteStorageServiceProvider = Provider<RemoteStorageService>((ref) {
  return SupabaseServices(ref.watch(supabaseClient));
});

final supabaseClient = Provider<SupabaseClient>((ref) {
  return SupabaseClient(
    const String.fromEnvironment('SUPABASE_URL'),
    const String.fromEnvironment('SUPABASE_PUBLIC_KEY'),
  );
});

class SupabaseServices implements RemoteStorageService {
  SupabaseServices(this.supabaseClient);

  SupabaseClient supabaseClient;

  @override
  TaskEither<String, String> uploadFile(File file) {
    return TaskEither.tryCatch(
      () async {
        await supabaseClient.storage
            .from('uploads') //
            .upload(
              basename(file.path),
              file,
              fileOptions: const FileOptions(upsert: true),
            );
        return supabaseClient.storage
            .from('uploads') //
            .getPublicUrl(
              basename(file.path),
            );
      },
      (error, stackTrace) {
        return 'Cannot upload file ${file.path}: $error';
      },
    );
  }
}
