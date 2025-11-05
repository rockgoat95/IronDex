import 'package:flutter/foundation.dart';
import 'package:irondex/models/free_weight.dart';
import 'package:irondex/services/core/supabase_service.dart';
import 'package:irondex/services/repositories/free_weight_repository.dart';
import 'package:irondex/services/supabase/supabase_query_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseFreeWeightRepository extends SupabaseService
    implements FreeWeightRepository {
  SupabaseFreeWeightRepository({super.client});

  PostgrestTransformBuilder _buildFreeWeightQuery({
    List<String>? bodyParts,
    String? searchQuery,
    required String selectClause,
  }) {
    PostgrestFilterBuilder query = client
        .schema('catalog')
        .from('freeweights')
        .select(selectClause);

    if (bodyParts != null && bodyParts.isNotEmpty) {
      query = query.overlaps('body_parts', bodyParts);
    }

    final trimmed = searchQuery?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      final pattern = '%${escapeForLikeQuery(trimmed)}%';
      query = query.ilike('name', pattern);
    }

    return query.order('name');
  }

  @override
  Future<List<FreeWeight>> fetchFreeWeights({
    List<String>? bodyParts,
    String? searchQuery,
    int offset = 0,
    int limit = 20,
  }) async {
    final query = _buildFreeWeightQuery(
      bodyParts: bodyParts,
      searchQuery: searchQuery,
      selectClause: 'id, name, image_url, body_parts',
    );

    final response = await query.range(offset, offset + limit - 1);
    final rows = List<Map<String, dynamic>>.from(response);
    final data = rows.map(FreeWeight.fromMap).toList();

    if (kDebugMode) {
      debugPrint(
        '[SupabaseFreeWeightRepository] fetchFreeWeights count=${data.length} '
        'filters={bodyParts: $bodyParts, searchQuery: $searchQuery}',
      );
    }

    return data;
  }
}
