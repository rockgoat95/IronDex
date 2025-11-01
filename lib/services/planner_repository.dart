import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:irondex/models/planner_routine.dart';
import 'package:irondex/models/routine_exercise_draft.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlannerRepositoryException implements Exception {
  PlannerRepositoryException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'PlannerRepositoryException(message: $message, cause: $cause)';
}

class PlannerRepository {
  PlannerRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');
  static final RegExp _hexPattern = RegExp(r'^[0-9a-fA-F]+$');
  static final BigInt _maxSignedBigInt = BigInt.parse(
    '7fffffffffffffff',
    radix: 16,
  );

  Future<PlannerRoutine?> fetchRoutine(DateTime date) async {
    final userId = _requireUserId();
    final dateKey = _dateFormatter.format(date);

    final response = await _client
        .schema('planner')
        .from('workouts')
        .select(
          'id, user_id, date, name, status, '
          'workout_items(id, item_order, item_type, reference_id, memo, '
          'workout_item_sets(id, set_order, set_type, weight, reps, is_completed))',
        )
        .eq('user_id', userId)
        .eq('date', dateKey)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    final workoutId = (response['id'] as num?)?.toInt();
    if (workoutId == null) {
      throw PlannerRepositoryException(
        'Failed to load the routine identifier.',
      );
    }

    final rawDate = response['date'];
    final parsedDate = rawDate is String
        ? DateTime.parse(rawDate)
        : (rawDate is DateTime ? rawDate : date);
    final status = PlannerRoutineStatusMapper.fromSupabaseValue(
      response['status'] as String?,
    );
    final name = response['name'] as String?;

    final exercisesWithOrder = <MapEntry<int, RoutineExerciseDraft>>[];
    final rawItems = response['workout_items'];
    if (rawItems is List) {
      for (final raw in rawItems) {
        Map<String, dynamic>? map;
        if (raw is Map<String, dynamic>) {
          map = raw;
        } else if (raw is Map) {
          map = Map<String, dynamic>.from(raw.cast());
        }
        if (map == null) {
          continue;
        }
        final type = map['item_type']?.toString();
        if (type != 'machine') {
          continue;
        }
        final order =
            (map['item_order'] as num?)?.toInt() ??
            (exercisesWithOrder.length + 1);
        exercisesWithOrder.add(MapEntry(order, _mapItemToExercise(map)));
      }
      exercisesWithOrder.sort((a, b) => a.key.compareTo(b.key));
    }

    final items = exercisesWithOrder.map((entry) => entry.value).toList();

    return PlannerRoutine(
      id: workoutId,
      userId: userId,
      date: parsedDate,
      name: name,
      status: status,
      exercises: items,
    );
  }

  Future<PlannerRoutine> saveRoutineDraft({
    int? workoutId,
    required DateTime date,
    String? name,
    required List<RoutineExerciseDraft> exercises,
    PlannerRoutineStatus status = PlannerRoutineStatus.draft,
  }) async {
    final userId = _requireUserId();
    final trimmedName = name?.trim();
    final nullableName = (trimmedName == null || trimmedName.isEmpty)
        ? null
        : trimmedName;
    final dateKey = _dateFormatter.format(date);

    final List<RoutineExerciseDraft> clonedExercises =
        List<RoutineExerciseDraft>.from(exercises);

    int resolvedWorkoutId;
    if (workoutId == null) {
      final insertResponse = await _client
          .schema('planner')
          .from('workouts')
          .insert({
            'user_id': userId,
            'date': dateKey,
            'name': nullableName,
            'status': status.supabaseValue,
          })
          .select('id')
          .maybeSingle();

      final insertedId = (insertResponse?['id'] as num?)?.toInt();
      if (insertedId == null) {
        throw PlannerRepositoryException('Failed to create the routine.');
      }
      resolvedWorkoutId = insertedId;
    } else {
      resolvedWorkoutId = workoutId;
      await _client
          .schema('planner')
          .from('workouts')
          .update({'name': nullableName, 'status': status.supabaseValue})
          .eq('id', resolvedWorkoutId);
    }

    await _replaceWorkoutItems(
      workoutId: resolvedWorkoutId,
      exercises: clonedExercises,
    );

    return PlannerRoutine(
      id: resolvedWorkoutId,
      userId: userId,
      date: date,
      name: nullableName,
      status: status,
      exercises: clonedExercises,
    );
  }

  Future<bool> hasIncompleteRoutine(DateTime date) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return false;
    }

    final dateKey = _dateFormatter.format(date);
    final response = await _client
        .schema('planner')
        .from('workouts')
        .select('id, status')
        .eq('user_id', userId)
        .eq('date', dateKey)
        .maybeSingle();

    if (response == null) {
      return false;
    }

    final status = PlannerRoutineStatusMapper.fromSupabaseValue(
      response['status'] as String?,
    );
    return status != PlannerRoutineStatus.completed;
  }

  Future<void> _replaceWorkoutItems({
    required int workoutId,
    required List<RoutineExerciseDraft> exercises,
  }) async {
    final existingItemsResponse = await _client
        .schema('planner')
        .from('workout_items')
        .select('id')
        .eq('workout_id', workoutId);
    final existingItemsRaw =
        (existingItemsResponse as List?) ?? const <dynamic>[];
    final existingItemIds = <int>[];
    for (final raw in existingItemsRaw) {
      if (raw is Map<String, dynamic>) {
        final id = (raw['id'] as num?)?.toInt();
        if (id != null) {
          existingItemIds.add(id);
        }
      } else if (raw is Map) {
        final map = Map<String, dynamic>.from(raw.cast<Object?, Object?>());
        final id = (map['id'] as num?)?.toInt();
        if (id != null) {
          existingItemIds.add(id);
        }
      }
    }

    if (existingItemIds.isNotEmpty) {
      await _client
          .schema('planner')
          .from('workout_item_sets')
          .delete()
          .inFilter('item_id', existingItemIds);
    }

    await _client
        .schema('planner')
        .from('workout_items')
        .delete()
        .eq('workout_id', workoutId);

    for (var index = 0; index < exercises.length; index++) {
      final exercise = exercises[index];
      final referenceId = _resolveReferenceId(
        exercise.machineId,
        seed: index + 1,
      );
      final memo = jsonEncode(_createMemoPayload(exercise));

      final insertResponse = await _client
          .schema('planner')
          .from('workout_items')
          .insert({
            'workout_id': workoutId,
            'item_order': index + 1,
            'item_type': 'machine',
            'reference_id': referenceId,
            'memo': memo,
          })
          .select('id')
          .maybeSingle();

      final itemId = (insertResponse?['id'] as num?)?.toInt();
      if (itemId == null) {
        if (kDebugMode) {
          debugPrint(
            '[PlannerRepository] workout_item insert failed index=$index',
          );
        }
        continue;
      }

      final setPayload = exercise.sets
          .map<Map<String, dynamic>>(
            (set) => {
              'item_id': itemId,
              'set_order': set.order,
              'set_type': set.type.supabaseValue,
              'weight': set.weight,
              'reps': set.reps,
              'is_completed': set.isCompleted,
            },
          )
          .toList();

      if (setPayload.isEmpty) {
        continue;
      }

      await _client
          .schema('planner')
          .from('workout_item_sets')
          .insert(setPayload);
    }
  }

  RoutineExerciseDraft _mapItemToExercise(Map<String, dynamic> item) {
    String machineId = item['reference_id']?.toString() ?? '';
    final memoValue = item['memo'];
    String? machineName;
    String? brandName;
    String? brandLogoUrl;
    String? imageUrl;

    if (memoValue is String && memoValue.isNotEmpty) {
      try {
        final decoded = jsonDecode(memoValue);
        Map<String, dynamic>? memoMap;
        if (decoded is Map<String, dynamic>) {
          memoMap = decoded;
        } else if (decoded is Map) {
          memoMap = Map<String, dynamic>.from(decoded.cast());
        }
        if (memoMap != null) {
          final storedMachineId = memoMap['machineId']?.toString();
          if (storedMachineId != null && storedMachineId.isNotEmpty) {
            machineId = storedMachineId;
          }
          machineName = memoMap['machineName']?.toString() ?? machineName;
          brandName = memoMap['brandName']?.toString() ?? brandName;
          brandLogoUrl = memoMap['brandLogoUrl']?.toString() ?? brandLogoUrl;
          imageUrl = memoMap['imageUrl']?.toString() ?? imageUrl;
        }
      } catch (error) {
        if (kDebugMode) {
          debugPrint('[PlannerRepository] memo decode error=$error');
        }
      }
    }

    final rawSets = item['workout_item_sets'];
    final sets = <RoutineExerciseSetDraft>[];
    if (rawSets is List) {
      for (final rawSet in rawSets) {
        Map<String, dynamic>? map;
        if (rawSet is Map<String, dynamic>) {
          map = rawSet;
        } else if (rawSet is Map) {
          map = Map<String, dynamic>.from(rawSet.cast());
        }
        if (map == null) {
          continue;
        }
        final order = (map['set_order'] as num?)?.toInt() ?? (sets.length + 1);
        final weight = (map['weight'] as num?)?.toDouble();
        final reps = (map['reps'] as num?)?.toInt();
        final type = RoutineExerciseSetTypeDbMapper.fromSupabaseValue(
          map['set_type']?.toString(),
        );
        final isCompleted = map['is_completed'] as bool? ?? false;
        sets.add(
          RoutineExerciseSetDraft(
            order: order,
            weight: weight,
            reps: reps,
            type: type,
            isCompleted: isCompleted,
          ),
        );
      }
      sets.sort((a, b) => a.order.compareTo(b.order));
    }

    return RoutineExerciseDraft(
      machineId: machineId,
      machineName: machineName ?? 'Machine',
      brandName: brandName,
      brandLogoUrl: brandLogoUrl,
      imageUrl: imageUrl,
      sets: sets,
    );
  }

  Map<String, dynamic> _createMemoPayload(RoutineExerciseDraft exercise) {
    return <String, dynamic>{
      'machineId': exercise.machineId,
      'machineName': exercise.machineName,
      if (exercise.brandName != null) 'brandName': exercise.brandName,
      if (exercise.brandLogoUrl != null) 'brandLogoUrl': exercise.brandLogoUrl,
      if (exercise.imageUrl != null) 'imageUrl': exercise.imageUrl,
    };
  }

  int _resolveReferenceId(String machineId, {required int seed}) {
    final trimmed = machineId.trim();
    if (trimmed.isEmpty) {
      return seed;
    }

    final numeric = int.tryParse(trimmed);
    if (numeric != null) {
      return numeric;
    }

    final normalized = trimmed.replaceAll('-', '');
    if (normalized.isNotEmpty && _hexPattern.hasMatch(normalized)) {
      try {
        final big = BigInt.parse(normalized, radix: 16);
        final masked = big & _maxSignedBigInt;
        final value = masked.toInt();
        if (value != 0) {
          return value;
        }
      } catch (_) {
        // keep hashing fallback
      }
    }

    final hashed = _stableHash64(trimmed);
    if (hashed != 0) {
      return hashed;
    }

    return seed;
  }

  int _stableHash64(String input) {
    final bytes = utf8.encode(input);
    BigInt hash = BigInt.from(0xcbf29ce484222325);
    const int fnvPrime = 0x100000001b3;
    for (final byte in bytes) {
      hash = (hash ^ BigInt.from(byte)) * BigInt.from(fnvPrime);
      hash &= _maxSignedBigInt;
    }
    return hash.toInt();
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw PlannerRepositoryException('Login is required.');
    }
    return userId;
  }
}
