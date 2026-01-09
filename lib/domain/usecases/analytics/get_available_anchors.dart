import 'package:dartz/dartz.dart';
import 'package:mobile_project_spending_management/core/errors/failures.dart';
import 'package:mobile_project_spending_management/domain/repositories/analytics_repository.dart';

class GetAvailableAnchors {
  final AnalyticsRepository repository;
  GetAvailableAnchors(this.repository);

  Future<Either<Failure, List<DateTime>>> call({required String period}) {
    return repository.getAvailableAnchors(period: period);
  }
}
