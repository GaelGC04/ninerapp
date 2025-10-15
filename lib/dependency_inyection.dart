import 'package:get_it/get_it.dart';
import 'package:ninerapp/data/repositories/parent_repository.dart';
import 'package:ninerapp/data/repositories/service_repository.dart';
import 'package:ninerapp/domain/repositories/iparent_repository.dart';
import 'package:ninerapp/domain/repositories/iservice_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ninerapp/data/repositories/babysitter_repository.dart';
import 'package:ninerapp/data/repositories/child_repository.dart';
import 'package:ninerapp/domain/repositories/ibabysitter_repository.dart';
import 'package:ninerapp/domain/repositories/ichild_repository.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Se llama al supabase cliente
  getIt.registerSingleton<SupabaseClient>(Supabase.instance.client);

  // Aquí se añaden los repositorios
  getIt.registerSingleton<IChildRepository>(ChildRepository(supabase: getIt<SupabaseClient>()));
  getIt.registerSingleton<IBabysitterRepository>(BabysitterRepository(supabase: getIt<SupabaseClient>()));
  getIt.registerSingleton<IServiceRepository>(ServiceRepository(supabase: getIt<SupabaseClient>()));
  getIt.registerSingleton<IParentRepository>(ParentRepository(supabase: getIt<SupabaseClient>()));
}