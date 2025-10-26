import 'package:irondex/models/catalog/machine.dart';

abstract class MachineRepository {
  const MachineRepository();

  Future<List<Machine>> fetchMachines({
    String? brandId,
    List<String>? bodyParts,
    String? machineType,
    String? searchQuery,
    int offset = 0,
    int limit = 20,
  });

  Future<List<Machine>> searchMachines(String keyword, {int limit = 20});

  Future<Set<String>> fetchFavoriteMachineIds();

  Future<void> addFavoriteMachine(String machineId);

  Future<void> removeFavoriteMachine(String machineId);
}
