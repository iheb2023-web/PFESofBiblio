import 'package:app/models/book.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/controllers/theme_controller.dart';
import 'package:table_calendar/table_calendar.dart';

class EmprunterLivre extends StatefulWidget {
  final Book book;

  const EmprunterLivre({Key? key, required this.book}) : super(key: key);

  @override
  State<EmprunterLivre> createState() => _EmprunterLivreState();
}

class _EmprunterLivreState extends State<EmprunterLivre> {
  DateTime? dateEmprunt;
  DateTime? dateRetour;
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder:
          (themeController) => Scaffold(
            appBar: AppBar(title: Text('Emprunter'.tr)),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section détails du livre
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Couverture du livre
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          widget.book.coverUrl,
                          height: 200,
                          width: 140,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Informations du livre
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.book.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.book.author,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            // Notation étoiles
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < widget.book.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                );
                              }),
                            ),
                            const SizedBox(height: 16),
                            // État de disponibilité
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    widget.book.isAvailable
                                        ? Colors.green
                                        : Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.book.isAvailable
                                    ? 'disponible'.tr
                                    : 'non_disponible'.tr,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Informations supplémentaires
                  _buildInfoRow('ISBN', widget.book.isbn),
                  _buildInfoRow('category'.tr, widget.book.category),
                  _buildInfoRow('pages'.tr, '${widget.book.pageCount}'),
                  _buildInfoRow(
                    'status'.tr,
                    widget.book.isAvailable ? 'en_stock'.tr : 'emprunte'.tr,
                  ),

                  const SizedBox(height: 24),

                  // Calendrier
                  Container(
                    decoration: BoxDecoration(
                      color:
                          themeController.isDarkMode
                              ? AppTheme.darkSurfaceColor
                              : AppTheme.lightSurfaceColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) {
                        return isSameDay(dateEmprunt, day) ||
                            isSameDay(dateRetour, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          if (dateEmprunt == null) {
                            dateEmprunt = selectedDay;
                          } else if (dateRetour == null &&
                              selectedDay.isAfter(dateEmprunt!)) {
                            dateRetour = selectedDay;
                          } else {
                            dateEmprunt = selectedDay;
                            dateRetour = null;
                          }
                          _focusedDay = focusedDay;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Dates sélectionnées
                  if (dateEmprunt != null)
                    _buildDateRow('date_emprunt'.tr, dateEmprunt!),
                  if (dateRetour != null)
                    _buildDateRow('date_retour'.tr, dateRetour!),

                  const SizedBox(height: 24),

                  // Résumé de réservation
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          themeController.isDarkMode
                              ? AppTheme.darkSurfaceColor
                              : AppTheme.lightSurfaceColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'resume_reservation'.tr,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        if (dateEmprunt != null && dateRetour != null)
                          Text(
                            'duree'.trParams({
                              'jours':
                                  '${dateRetour!.difference(dateEmprunt!).inDays}',
                            }),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              (dateEmprunt != null && dateRetour != null)
                                  ? () {
                                    // Logique de réservation
                                  }
                                  : null,
                          child: Text('reserver_maintenant'.tr),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            '${date.day}/${date.month}/${date.year}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
