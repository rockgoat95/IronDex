import 'dart:async';

import 'package:flutter/material.dart';
import 'package:irondex/models/catalog/machine.dart';
import 'package:irondex/widgets/reviews/lists/machine_list.dart';

class MachinePickerSheet extends StatefulWidget {
  const MachinePickerSheet({super.key});

  @override
  State<MachinePickerSheet> createState() => _MachinePickerSheetState();
}

class _MachinePickerSheetState extends State<MachinePickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String? _searchQuery;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    setState(() {});
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final trimmed = value.trim();
      setState(() {
        _searchQuery = trimmed.isEmpty ? null : trimmed;
      });
    });
  }

  void _onSearchSubmitted(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    FocusScope.of(context).unfocus();
    setState(() {
      _searchQuery = trimmed.isEmpty ? null : trimmed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Select Machine',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onSubmitted: _onSearchSubmitted,
                  decoration: InputDecoration(
                    hintText: 'Search machine name',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: (_searchController.text.isEmpty)
                        ? null
                        : IconButton(
                            onPressed: () {
                              _debounce?.cancel();
                              _searchController.clear();
                              setState(() {
                                _searchQuery = null;
                              });
                            },
                            icon: const Icon(Icons.clear),
                            tooltip: 'Clear search',
                          ),
                    border: const OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.search,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Scrollbar(
                    controller: _scrollController,
                    child: PrimaryScrollController(
                      controller: _scrollController,
                      child: MachineList(
                        parentScrollController: _scrollController,
                        searchQuery: _searchQuery,
                        standalone: true,
                        onMachineTap: (Machine machine) {
                          Navigator.of(context).pop(machine);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
