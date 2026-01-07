import 'package:get_it/get_it.dart';
import 'package:mobile_project_spending_management/data/datasources/local/app_database.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Database
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Repositories
  // TODO: Register repositories when implemented

  // Use Cases
  // TODO: Register use cases when implemented

  // Blocs
  // TODO: Register blocs when implemented

  // Services
  // TODO: Register notification service, analytics service, etc.
}
