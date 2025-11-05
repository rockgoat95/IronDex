import 'dart:async';

import 'package:flutter/material.dart';

typedef MachinePickerListBuilder =
    Widget Function(
      BuildContext context,
      ScrollController scrollController,
      String? searchQuery,
    );

class MachinePickerContent extends StatefulWidget {
  const MachinePickerContent({
    super.key,
    required this.listBuilder,
    this.title = 'Select Machine',
    this.searchHint = 'Search machine name',
    this.onClose,
    this.additionalSections = const <Widget>[],
    this.initialSearchQuery,
  });

  final MachinePickerListBuilder listBuilder;
  final String title;
  final String searchHint;
  final VoidCallback? onClose;
  final List<Widget> additionalSections;
  final String? initialSearchQuery;

  @override
  State<MachinePickerContent> createState() => _MachinePickerContentState();
}

class _MachinePickerContentState extends State<MachinePickerContent> {
  late final TextEditingController _searchController;
  Timer? _debounce;
  String? _searchQuery;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final initialText = widget.initialSearchQuery ?? '';
    _searchQuery = initialText.trim().isEmpty ? null : initialText.trim();
    _searchController = TextEditingController(text: initialText);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSearchChanged(String value) {
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

  void _handleSearchSubmitted(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    FocusScope.of(context).unfocus();
    setState(() {
      _searchQuery = trimmed.isEmpty ? null : trimmed;
    });
  }

  void _handleSearchClear() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      _searchQuery = null;
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
                        widget.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (widget.onClose != null)
                      IconButton(
                        onPressed: widget.onClose,
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
                  onChanged: _handleSearchChanged,
                  onSubmitted: _handleSearchSubmitted,
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: (_searchController.text.isEmpty)
                        ? null
                        : IconButton(
                            onPressed: _handleSearchClear,
                            icon: const Icon(Icons.clear),
                            tooltip: 'Clear search',
                          ),
                    border: const OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.search,
                ),
              ),
              if (widget.additionalSections.isNotEmpty) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < widget.additionalSections.length; i++)
                        Padding(
                          padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
                          child: widget.additionalSections[i],
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Scrollbar(
                    controller: _scrollController,
                    child: PrimaryScrollController(
                      controller: _scrollController,
                      child: widget.listBuilder(
                        context,
                        _scrollController,
                        _searchQuery,
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
