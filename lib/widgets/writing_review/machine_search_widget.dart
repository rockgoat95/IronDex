import 'package:flutter/material.dart';
import '../../supabase/fetcher.dart';
import '../../supabase/search.dart';

class MachineSearchWidget extends StatefulWidget {
  final String? selectedMachineName;
  final Function(String machineId, String machineName) onMachineSelected;

  const MachineSearchWidget({
    super.key,
    this.selectedMachineName,
    required this.onMachineSelected,
  });

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

  // 머신 검색 함수
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
    } catch (e) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
    }
  }

  // 머신 선택 함수
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
        // 머신 선택 섹션 제목
        const Text(
          'Select Machine',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // 머신 선택 버튼
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
                    widget.selectedMachineName != null 
                      ? widget.selectedMachineName! 
                      : '머신을 검색해주세요',
                    style: TextStyle(
                      color: widget.selectedMachineName != null 
                        ? Colors.black 
                        : Colors.grey.shade600,
                    ),
                  ),
                ),
                Icon(
                  _isSearchExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
        
        // 검색창 (AnimatedContainer로 펼쳐지는 효과)
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
                    // 검색 텍스트필드
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
                    
                    // 검색 결과 리스트
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
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 40,
                                      height: 40,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.fitness_center, size: 20),
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
