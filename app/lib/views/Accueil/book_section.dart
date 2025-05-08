import 'package:app/controllers/review_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/models/book.dart';
import 'package:app/views/Détails_Livre/details_livre.dart';
import 'package:app/controllers/book_controller.dart';

class BookSection extends StatelessWidget {
  final String title;
  final List<Book> books;
  final bool isHorizontal;

  const BookSection({
    super.key,
    required this.title,
    required this.books,
    required this.isHorizontal,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bookController = Get.find<BookController>();

      if (bookController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (bookController.error.value.isNotEmpty) {
        return Center(child: Text(bookController.error.value));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {}, // View all action
                  child: Text('view_all'.tr),
                ),
              ],
            ),
          ),
          isHorizontal ? _buildHorizontalList() : _buildVerticalList(),
        ],
      );
    });
  }

  Widget _buildHorizontalList() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder:
            (context, index) =>
                _BookCard(book: books[index], isHorizontal: true),
      ),
    );
  }

  Widget _buildVerticalList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: books.length,
      padding: EdgeInsets.zero,
      itemBuilder:
          (context, index) =>
              _BookCard(book: books[index], isHorizontal: false),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  final bool isHorizontal;

  const _BookCard({required this.book, required this.isHorizontal});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => DetailsLivre(book: book)),
      child:
          isHorizontal
              ? Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BookCover(book: book, height: 200),
                    const SizedBox(height: 8),
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 4),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber[700]),
                        const SizedBox(
                          width: 4.0,
                        ), // Add spacing between icon and text
                        Flexible(
                          child: FutureBuilder<String>(
                            future: _getAverageStars(book),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                  width: 16.0,
                                  height: 16.0,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return const Text(
                                  'Erreur',
                                  style: TextStyle(fontSize: 12.0),
                                  overflow: TextOverflow.ellipsis,
                                );
                              } else if (snapshot.hasData) {
                                return Text(
                                  '${snapshot.data!}/5',
                                  style: const TextStyle(fontSize: 12.0),
                                  overflow: TextOverflow.ellipsis,
                                );
                              }
                              return const Text(
                                '0.0/5',
                                style: TextStyle(fontSize: 12.0),
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
              : Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      _BookCover(book: book, height: 120, width: 80),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book.author,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.people_outline,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'borrowed_times'.trParams({
                                    'count': '${book.borrowCount}',
                                  }),
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: book.isAvailable ? () {} : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    minimumSize: const Size(120, 36),
                                  ),
                                  child: Text(
                                    book.isAvailable
                                        ? 'borrow'.tr
                                        : 'unavailable'.tr,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

Future<String> _getAverageStars(Book book) async {
  final reviewController = Get.find<ReviewController>();
  final average = await reviewController.averageStars(book.id!);
  return average.toStringAsFixed(1);
}

class _BookCover extends StatelessWidget {
  final Book book;
  final double height;
  final double? width;

  const _BookCover({required this.book, required this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        book.coverUrl,
        height: height,
        width: width,
        fit: BoxFit.cover,
        cacheWidth: width != null ? (width! * 2).toInt() : 600,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: height,
            width: width,
            color: Colors.grey[200],
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder:
            (context, error, stackTrace) => Container(
              height: height,
              width: width,
              color: Colors.grey[200],
              child: Icon(Icons.book, size: width != null ? 30 : 50),
            ),
      ),
    );
  }
}
