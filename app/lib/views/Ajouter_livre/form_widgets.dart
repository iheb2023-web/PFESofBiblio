import 'package:app/models/book_model_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:app/themeData.dart' as theme_data;

Widget buildLabel(String text) {
  return Text(text, style: Theme.of(Get.context!).textTheme.bodyLarge);
}

Widget buildTextField(
  TextEditingController controller,
  String hint, {
  bool isLoading = false,
}) {
  return Stack(
    alignment: Alignment.centerRight,
    children: [
      TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: Theme.of(Get.context!).inputDecorationTheme.hintStyle,
          border: Theme.of(Get.context!).inputDecorationTheme.border,
          enabledBorder:
              Theme.of(Get.context!).inputDecorationTheme.enabledBorder,
          focusedBorder:
              Theme.of(Get.context!).inputDecorationTheme.focusedBorder,
          fillColor: Theme.of(Get.context!).inputDecorationTheme.fillColor,
          filled: true,
          contentPadding: EdgeInsets.only(
            left: 16,
            right: isLoading ? 48 : 16,
            top: 16,
            bottom: 16,
          ),
        ),
        style: Theme.of(Get.context!).textTheme.bodyLarge,
      ),
      if (isLoading)
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(Get.context!).primaryColor,
              ),
            ),
          ),
        ),
    ],
  );
}

Widget buildEditableField(
  String label,
  TextEditingController controller, {
  bool readOnly = false,
  TextInputType? keyboardType,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(Get.context!).textTheme.titleMedium),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Theme.of(Get.context!).cardColor,
        ),
        style: Theme.of(Get.context!).textTheme.bodyMedium,
      ),
    ],
  );
}

Widget buildAddButton(VoidCallback onPressed) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: Text(
        'add'.tr,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme_data.blueColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

class BookDetailsSection extends StatelessWidget {
  final BookData bookData;
  final TextEditingController isbnController;
  final TextEditingController pageCountController;
  final TextEditingController languageController;
  final TextEditingController categoryController;
  final TextEditingController descriptionController;
  final String publishedDate;

  const BookDetailsSection({
    super.key,
    required this.bookData,
    required this.isbnController,
    required this.pageCountController,
    required this.languageController,
    required this.categoryController,
    required this.descriptionController,
    required this.publishedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: buildEditableField('ISBN', isbnController)),
            const SizedBox(width: 16),
            Expanded(
              child: buildEditableField(
                'Publication_date'.tr,
                TextEditingController(text: publishedDate),
                readOnly: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: buildEditableField(
                'Number_of_pages'.tr,
                pageCountController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: buildEditableField('language'.tr, languageController),
            ),
          ],
        ),
        const SizedBox(height: 16),
        buildEditableField('Category'.tr, categoryController),
        const SizedBox(height: 16),
        Text('Description'.tr, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: descriptionController,
          maxLines: 5,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).cardColor,
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class GeneratedContentSection extends StatelessWidget {
  final BookData? bookData;

  const GeneratedContentSection({super.key, required this.bookData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Generated_content'.tr,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).cardColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).cardColor),
                  image:
                      bookData != null && bookData!.coverUrl.isNotEmpty
                          ? DecorationImage(
                            image: NetworkImage(bookData!.coverUrl),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    bookData == null || bookData!.coverUrl.isEmpty
                        ? Icon(
                          Icons.image,
                          color: Theme.of(context).iconTheme.color,
                          size: 32,
                        )
                        : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Summary'.tr,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bookData != null && bookData!.description.isNotEmpty
                          ? bookData!.description
                          : 'Le résumé sera généré automatiquement...',
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AvailabilitySection extends StatelessWidget {
  final DateTime? selectedDate;
  final TextEditingController durationController;
  final ValueChanged<DateTime?> onDateSelected;

  const AvailabilitySection({
    super.key,
    required this.selectedDate,
    required this.durationController,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Availability'.tr,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(
                      context,
                    ).colorScheme.copyWith(primary: theme_data.blueColor),
                  ),
                  child: child!,
                );
              },
            );
            if (pickedDate != null) {
              onDateSelected(pickedDate);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border.all(color: Theme.of(context).cardColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                      : 'Sélectionner une date',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Theme.of(context).iconTheme.color,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Durée du prêt'.tr,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: durationController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).cardColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).cardColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme_data.blueColor),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                fillColor: Theme.of(context).cardColor,
                filled: true,
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ],
    );
  }
}
