import 'package:irondex/models/free_weight.dart';

abstract class FreeWeightRepository {
  const FreeWeightRepository();

  Future<List<FreeWeight>> fetchFreeWeights({
    List<String>? bodyParts,
    String? searchQuery,
    int offset = 0,
    int limit = 20,
  });
}
