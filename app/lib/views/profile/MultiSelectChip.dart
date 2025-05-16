import 'package:flutter/material.dart';

class MultiSelectChip extends StatefulWidget {
  final List<String> allItems;
  final List<String> selectedItems;
  final Function(List<String>) onSelectionChanged;

  const MultiSelectChip({
    super.key,
    required this.allItems,
    required this.selectedItems,
    required this.onSelectionChanged,
  });

  @override
  State<MultiSelectChip> createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children:
          widget.allItems.map((item) {
            final isSelected = widget.selectedItems.contains(item);
            return ChoiceChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    widget.selectedItems.add(item);
                  } else {
                    widget.selectedItems.remove(item);
                  }
                  widget.onSelectionChanged(widget.selectedItems);
                });
              },
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
    );
  }
}
//voila
//test