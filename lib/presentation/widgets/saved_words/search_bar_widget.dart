import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onClear;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextField(
      controller: widget.controller,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search saved words...',
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
                onPressed: widget.onClear,
                icon: const Icon(Icons.clear),
              )
            : null,
      ),
      style: TextStyle(
        color: theme.colorScheme.onSurface,
        fontSize: 16,
      ),
      onChanged: widget.onChanged,
    );
  }
}