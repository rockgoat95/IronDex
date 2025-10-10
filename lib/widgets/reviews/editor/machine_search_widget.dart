import 'package:flutter/material.dart';

import '../../../supabase/search.dart';

class MachineSearchWidget extends StatefulWidget {
  const MachineSearchWidget({
    super.key,
    this.selectedMachineName,
    required this.onMachineSelected,
  });

  final String? selectedMachineName;
  final void Function(String machineId, String machineName) onMachineSelected;

  @override
  State<MachineSearchWidget> createState() => _MachineSearchWidgetState();
}

class _MachineSearchWidgetState extends State<MachineSearchWidget> {
  final _searchController = TextEditingController();
  bool _isSearchExpanded = false;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchMachines(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await searchMachines(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (_) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
    }
  }

  void _selectMachine(Map<String, dynamic> machine) {
    final machineId = machine['id']?.toString() ?? '';
    final machineName = machine['name'] ?? '';

    widget.onMachineSelected(machineId, machineName);

    setState(() {
      _isSearchExpanded = false;
      _searchController.clear();
      _searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Machine',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isSearchExpanded = !_isSearchExpanded;
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.selectedMachineName ?? '머신을 검색해주세요',
                    style: TextStyle(
                      color: widget.selectedMachineName != null
                          ? Colors.black
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
                Icon(
                  _isSearchExpanded
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isSearchExpanded ? 200 : 0,
          child: _isSearchExpanded
              ? Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: '머신 이름을 입력하세요',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: _searchMachines,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _isSearching
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final machine = _searchResults[index];
                                  final brand = machine['brand'] ?? {};

                                  return ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        machine['image_url'] ?? '',
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  color: Colors.grey.shade300,
                                                  child: const Icon(
                                                    Icons.fitness_center,
                                                    size: 20,
                                                  ),
                                                ),
                                      ),
                                    ),
                                    title: Text(
                                      machine['name'] ?? '',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    subtitle: Text(
                                      brand['name'] ?? '',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    onTap: () => _selectMachine(machine),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                )
              : null,
        ),
      ],
    );
  }
}
