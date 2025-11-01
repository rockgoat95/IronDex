import 'package:irondex/services/repositories/brand_repository.dart';
import 'package:irondex/services/repositories/machine_repository.dart';
import 'package:irondex/services/repositories/review_repository.dart';
import 'package:irondex/services/supabase/supabase_brand_repository.dart';
import 'package:irondex/services/supabase/supabase_machine_repository.dart';
import 'package:irondex/services/supabase/supabase_review_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceLocator {
  ServiceLocator._({
    required this.brandRepository,
    required this.machineRepository,
    required this.reviewRepository,
  });

  static ServiceLocator? _instance;

  final BrandRepository brandRepository;
  final MachineRepository machineRepository;
  final ReviewRepository reviewRepository;

  factory ServiceLocator.initialize({SupabaseClient? client}) {
    if (_instance != null) {
      return _instance!;
    }

    _instance = ServiceLocator._(
      brandRepository: SupabaseBrandRepository(client: client),
      machineRepository: SupabaseMachineRepository(client: client),
      reviewRepository: SupabaseReviewRepository(client: client),
    );

    return _instance!;
  }

  static ServiceLocator get instance =>
      _instance ?? ServiceLocator.initialize(client: Supabase.instance.client);
}
