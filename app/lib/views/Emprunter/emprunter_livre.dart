import 'package:app/models/book.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/controllers/theme_controller.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:app/controllers/borrow_controller.dart';
import 'package:app/views/Détails_Livre/details_livre.dart';

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

  // Remplacer _availabilityMap par _occupiedDates
  Map<DateTime, bool> _occupiedDates = {};

  final BorrowController _borrowController = Get.find<BorrowController>();

  @override
  void initState() {
    super.initState();
    _loadOccupiedDates();
  }

  // Ajouter la méthode pour charger les dates occupées
  void _loadOccupiedDates() async {
    try {
      final occupiedDates = await _borrowController.getOccupiedDatesByBookId(
        widget.book.id!,
      );

      setState(() {
        _occupiedDates = {
          for (var date in occupiedDates)
            DateTime(date.year, date.month, date.day): true,
        };
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement des dates occupées: $e');
      Get.rawSnackbar(
        message: 'Erreur lors du chargement des dates',
        backgroundColor: Colors.red[100]!,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder:
          (themeController) => Scaffold(
            appBar: AppBar(
              title: Text('Emprunter'.tr),
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor:
                  themeController.isDarkMode ? Colors.white : Colors.black,
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section détails du livre (comme dans l'image)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Couverture du livre
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.book.coverUrl,
                                height: 120,
                                width: 80,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      height: 120,
                                      width: 80,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.book),
                                    ),
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
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.book.author,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Notation étoiles
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.book.rating.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // État de disponibilité
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Disponible'.tr,
                            style: TextStyle(color: Colors.green[700]),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Informations supplémentaires (style liste)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('ISBN', widget.book.isbn),
                        _buildInfoRow('Catégorie', widget.book.category),
                        _buildInfoRow('Pages', '${widget.book.pageCount}'),
                        _buildInfoRow('Statut actuel', 'En stock'.tr),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Titre du calendrier
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Calendrier de disponibilité'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Calendrier
                  Column(
                    children: [
                      // Mois et navigation
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: () {
                                setState(() {
                                  _focusedDay = DateTime(
                                    _focusedDay.year,
                                    _focusedDay.month - 1,
                                    _focusedDay.day,
                                  );
                                });
                              },
                            ),
                            Text(
                              '${_getMonthName(_focusedDay.month)} ${_focusedDay.year}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () {
                                setState(() {
                                  _focusedDay = DateTime(
                                    _focusedDay.year,
                                    _focusedDay.month + 1,
                                    _focusedDay.day,
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      // Jours de la semaine
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:
                              ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                                  .map(
                                    (day) => SizedBox(
                                      width: 30,
                                      child: Center(
                                        child: Text(
                                          day,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Calendrier simplifié
                      _buildSimpleCalendar(),

                      const SizedBox(height: 16),

                      // Légende
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('Disponible'),
                            const SizedBox(width: 24),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('Indisponible'),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Dates sélectionnées
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dates sélectionnées',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (dateEmprunt != null)
                          _buildDateSelection(
                            'Date d\'emprunt',
                            dateEmprunt!,
                            Icons.calendar_today,
                            Colors.green,
                          ),
                        if (dateRetour != null)
                          _buildDateSelection(
                            'Date de retour',
                            dateRetour!,
                            Icons.event_busy,
                            Colors.red,
                          ),
                        if (dateEmprunt == null && dateRetour == null)
                          Text(
                            'Aucune date sélectionnée',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              dateEmprunt = null;
                              dateRetour = null;
                            });
                          },
                          child: Text('Effacer'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerRight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Résumé de réservation
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Résumé de la réservation',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          'Durée',
                          dateEmprunt != null && dateRetour != null
                              ? '${dateRetour!.difference(dateEmprunt!).inDays} jours'
                              : '-',
                        ),
                        _buildInfoRow('Statut', 'Disponible'),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                (dateEmprunt != null && dateRetour != null)
                                    ? () async {
                                      try {
                                        if (widget.book.id == null) {
                                          throw Exception(
                                            'ID du livre invalide',
                                          );
                                        }

                                        await _borrowController.borrowBook(
                                          widget.book.id!,
                                          dateEmprunt!,
                                          dateRetour!,
                                        );

                                        Get.snackbar(
                                          'Succès',
                                          'Livre réservé avec succès',
                                          snackPosition:
                                              SnackPosition
                                                  .BOTTOM, // ou SnackPosition.TOP selon ton design
                                          backgroundColor: Colors.green,
                                          colorText: Colors.white,
                                          borderRadius: 8,
                                          margin: const EdgeInsets.all(16),
                                          duration: const Duration(seconds: 2),
                                          icon: const Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                          ),
                                          shouldIconPulse: false,
                                        );

                                        // Attendre que le snackbar soit visible avant de naviguer
                                        await Future.delayed(
                                          const Duration(seconds: 2),
                                        );

                                        // Naviguer vers la page de détails
                                        Get.to(
                                          () => DetailsLivre(book: widget.book),
                                        );
                                      } catch (e) {
                                        // Journal pour débogage
                                        debugPrint(
                                          'Erreur lors de la réservation : $e',
                                        );

                                        String errorMessage = e.toString();
                                        if (errorMessage.startsWith(
                                          'Exception: ',
                                        )) {
                                          errorMessage = errorMessage.substring(
                                            11,
                                          );
                                        }
                                        Get.rawSnackbar(
                                          message: errorMessage,
                                          backgroundColor: Colors.red[100]!,
                                          snackPosition: SnackPosition.BOTTOM,
                                          duration: const Duration(seconds: 3),
                                          margin: const EdgeInsets.all(16),
                                          borderRadius: 8,
                                        );
                                      }
                                    }
                                    : null,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.bookmark),
                                const SizedBox(width: 8),
                                Text('Réserver maintenant'),
                              ],
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDateSelection(
    String label,
    DateTime date,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey[600])),
          const Spacer(),
          Text(
            '${date.day} ${_getMonthName(date.month)} ${date.year}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleCalendar() {
    final daysInMonth =
        DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    final today = DateTime.now();

    // Calculer le nombre de lignes nécessaires
    final totalDays = firstWeekday - 1 + daysInMonth;
    final numberOfWeeks = (totalDays / 7).ceil();

    List<Widget> weeks = [];

    int dayCounter = 1 - (firstWeekday - 1);

    for (int week = 0; week < numberOfWeeks; week++) {
      List<Widget> days = [];

      for (int i = 0; i < 7; i++) {
        if (dayCounter <= 0 || dayCounter > daysInMonth) {
          days.add(const SizedBox(width: 30, height: 30));
        } else {
          final currentDate = DateTime(
            _focusedDay.year,
            _focusedDay.month,
            dayCounter,
          );

          // Vérifier si la date est dans le passé (y compris aujourd'hui)
          final isPastDate =
              currentDate.isBefore(today) || isSameDay(currentDate, today);

          // Vérifier si la date est occupée
          final isOccupied = _occupiedDates.containsKey(currentDate);

          // La date est-elle indisponible?
          final isUnavailable = isPastDate || isOccupied;

          final isSelected =
              dateEmprunt != null && isSameDay(currentDate, dateEmprunt) ||
              dateRetour != null && isSameDay(currentDate, dateRetour);

          // Vérifier si la date est entre les dates sélectionnées
          final isBetweenDates =
              dateEmprunt != null &&
              dateRetour != null &&
              currentDate.isAfter(dateEmprunt!) &&
              currentDate.isBefore(dateRetour!) &&
              !isUnavailable; // Exclure les dates indisponibles de l'intervalle

          days.add(
            GestureDetector(
              onTap:
                  isUnavailable
                      ? null // Désactive le tap pour les dates indisponibles
                      : () {
                        setState(() {
                          if (dateEmprunt == null) {
                            dateEmprunt = currentDate;
                          } else if (dateRetour == null &&
                              currentDate.isAfter(dateEmprunt!)) {
                            // Vérifier qu'il n'y a pas de dates indisponibles dans l'intervalle
                            bool hasUnavailableDates = false;
                            DateTime checkDate = dateEmprunt!.add(
                              const Duration(days: 1),
                            );

                            while (checkDate.isBefore(currentDate)) {
                              final isCheckDateUnavailable =
                                  checkDate.isBefore(today) ||
                                  isSameDay(checkDate, today) ||
                                  _occupiedDates.containsKey(checkDate);

                              if (isCheckDateUnavailable) {
                                hasUnavailableDates = true;
                                break;
                              }
                              checkDate = checkDate.add(
                                const Duration(days: 1),
                              );
                            }

                            if (!hasUnavailableDates) {
                              dateRetour = currentDate;
                            } else {
                              Get.rawSnackbar(
                                message:
                                    'L\'intervalle contient des dates indisponibles',
                                backgroundColor: Colors.red[100]!,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          } else {
                            dateEmprunt = currentDate;
                            dateRetour = null;
                          }
                        });
                      },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color:
                      isUnavailable
                          ? isPastDate
                              ? Colors.grey[300]
                              : Colors.red[100]
                          : isSelected || isBetweenDates
                          ? Colors.blue
                          : Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    dayCounter.toString(),
                    style: TextStyle(
                      color:
                          isUnavailable
                              ? isPastDate
                                  ? Colors.grey[600]
                                  : Colors.red[900]
                              : isSelected || isBetweenDates
                              ? Colors.white
                              : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        dayCounter++;
      }

      weeks.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: days,
          ),
        ),
      );
    }

    return Column(children: weeks);
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return monthNames[month - 1];
  }
}
