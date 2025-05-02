import 'package:app/models/book_model_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'form_widgets.dart';

class AddBookForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController authorController;
  final TextEditingController descriptionController;
  final TextEditingController isbnController;
  final TextEditingController categoryController;
  final TextEditingController pageCountController;
  final TextEditingController languageController;
  final TextEditingController durationController;
  final BookData? bookData;
  final bool isLoading;
  final DateTime? selectedDate;
  final VoidCallback onAddBook;
  final ValueChanged<DateTime?> onDateSelected;

  const AddBookForm({
    super.key,
    required this.titleController,
    required this.authorController,
    required this.descriptionController,
    required this.isbnController,
    required this.categoryController,
    required this.pageCountController,
    required this.languageController,
    required this.durationController,
    required this.bookData,
    required this.isLoading,
    required this.selectedDate,
    required this.onAddBook,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildLabel('book_title'.tr),
          const SizedBox(height: 8),
          buildTextField(
            titleController,
            'enter_title'.tr,
            isLoading: isLoading,
          ),
          const SizedBox(height: 16),
          buildLabel('author'.tr),
          const SizedBox(height: 8),
          buildTextField(
            authorController,
            'enter_author'.tr,
            isLoading: isLoading,
          ),
          if (bookData != null) ...[
            const SizedBox(height: 16),
            BookDetailsSection(
              bookData: bookData!,
              isbnController: isbnController,
              pageCountController: pageCountController,
              languageController: languageController,
              categoryController: categoryController,
              descriptionController: descriptionController,
              publishedDate: bookData!.publishedDate,
            ),
          ],
          const SizedBox(height: 24),
          GeneratedContentSection(bookData: bookData),
          const SizedBox(height: 24),
          AvailabilitySection(
            selectedDate: selectedDate,
            durationController: durationController,
            onDateSelected: onDateSelected,
          ),
          const SizedBox(height: 24),
          buildAddButton(onAddBook),
        ],
      ),
    );
  }
}
