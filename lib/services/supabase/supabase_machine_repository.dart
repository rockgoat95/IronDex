import 'package:flutter/foundation.dart';
import 'package:irondex/models/catalog/machine.dart';
import 'package:irondex/services/core/supabase_service.dart';
import 'package:irondex/services/repositories/machine_repository.dart';
import 'package:irondex/services/supabase/supabase_query_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseMachineRepository extends SupabaseService
    implements MachineRepository {
  SupabaseMachineRepository({super.client});

  PostgrestFilterBuilder _buildMachineQuery({
    String? brandId,
    List<String>? bodyParts,
    String? machineType,
    String? searchQuery,
    required String selectClause,
  }) {
    var query = client
        .schema('catalog')
        .from('machines')
        .select(selectClause)
        .eq('status', 'approved');

    if (brandId != null && brandId.isNotEmpty) {
      query = query.eq('brand_id', brandId);
    }

    if (bodyParts != null && bodyParts.isNotEmpty) {
      query = query.overlaps('body_parts', bodyParts);
    }

    if (machineType != null && machineType.isNotEmpty) {
      query = query.eq('type', machineType);
    }

    final trimmedQuery = searchQuery?.trim();

    if (trimmedQuery != null && trimmedQuery.isNotEmpty) {
      final tokens = tokenizeSearchQuery(trimmedQuery);

      if (tokens.length <= 1) {
        final pattern = '%${escapeForLikeQuery(trimmedQuery)}%';
        query = query.ilike('search_text', pattern);
      } else {
        final uniqueTokens = tokens.toSet();
        for (final token in uniqueTokens) {
          final tokenPattern = '%${escapeForLikeQuery(token)}%';
          query = query.ilike('search_text', tokenPattern);
        }
      }
    }

    return query;
  }

  Map<String, dynamic> _mapMachineRow(Map<String, dynamic> machine) {
    final brand = <String, dynamic>{
      'id': machine['brand_id'],
      'name': machine['brand_name'],
      'name_kor': machine['brand_name_kor'],
      'logo_url': machine['brand_logo_url'],
    }..removeWhere((_, value) => value == null);

    return <String, dynamic>{...machine, if (brand.isNotEmpty) 'brand': brand};
  }

  @override
  Future<List<Machine>> fetchMachines({
    String? brandId,
    List<String>? bodyParts,
    String? machineType,
    String? searchQuery,
    int offset = 0,
    int limit = 20,
  }) async {
    final query = _buildMachineQuery(
      brandId: brandId,
      bodyParts: bodyParts,
      machineType: machineType,
      searchQuery: searchQuery,
      selectClause: '''
        id,
        name,
        status,
        image_url,
        review_cnt,
        score,
        body_parts,
        type,
        brand_id,
        brand_name,
        brand_name_kor,
        brand_logo_url
      ''',
    );

    final response = await query.range(offset, offset + limit - 1);
    final rows = List<Map<String, dynamic>>.from(response);
    final data = rows.map(_mapMachineRow).map(Machine.fromMap).toList();

    if (kDebugMode) {
      debugPrint(
        '[SupabaseMachineRepository] fetchMachines count=${data.length} '
        'filters={brandId: $brandId, bodyParts: $bodyParts, machineType: '
        '$machineType, searchQuery: $searchQuery}',
      );
      if (data.isNotEmpty) {
        debugPrint(
          '[SupabaseMachineRepository] fetchMachines first=${data.first}',
        );
      }
    }

    return data;
  }

  @override
  Future<List<Machine>> searchMachines(String keyword, {int limit = 20}) async {
    final trimmed = keyword.trim();

    if (trimmed.isEmpty) {
      return const <Machine>[];
    }

    final query = _buildMachineQuery(
      selectClause: '''
        id,
        name,
        status,
        image_url,
        review_cnt,
        score,
        body_parts,
        type,
        brand_id,
        brand_name,
        brand_name_kor,
        brand_logo_url
      ''',
      searchQuery: trimmed,
    );

    final response = await query.range(0, limit - 1);
    final rows = List<Map<String, dynamic>>.from(response);

    return rows.map(_mapMachineRow).map(Machine.fromMap).toList();
  }

  @override
  Future<Set<String>> fetchFavoriteMachineIds() async {
    final userId = client.auth.currentUser?.id;

    if (userId == null) {
      return <String>{};
    }

    final response = await client
        .schema('catalog')
        .from('machine_favorites')
        .select('machine_id')
        .eq('user_id', userId);

    final data = response
        .map<String>((row) => row['machine_id'].toString())
        .toSet();

    if (kDebugMode) {
      debugPrint(
        '[SupabaseMachineRepository] fetchFavoriteMachineIds count=${data.length}',
      );
    }

    return data;
  }

  @override
  Future<void> addFavoriteMachine(String machineId) async {
    final userId = client.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await client.schema('catalog').from('machine_favorites').upsert({
      'user_id': userId,
      'machine_id': machineId,
    }, onConflict: 'user_id,machine_id');

    if (kDebugMode) {
      debugPrint(
        '[SupabaseMachineRepository] addFavoriteMachine machineId=$machineId',
      );
    }
  }

  @override
  Future<void> removeFavoriteMachine(String machineId) async {
    final userId = client.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await client
        .schema('catalog')
        .from('machine_favorites')
        .delete()
        .eq('user_id', userId)
        .eq('machine_id', machineId);

    if (kDebugMode) {
      debugPrint(
        '[SupabaseMachineRepository] removeFavoriteMachine machineId=$machineId',
      );
    }
  }
}
