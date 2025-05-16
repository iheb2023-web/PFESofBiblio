import 'dart:convert';
import 'package:app/config/app_config.dart';
import 'package:app/models/borrow.dart';
import 'package:app/models/book.dart';
import 'package:app/enums/borrow_status.dart';
import 'package:app/services/storage_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class BorrowService extends GetxService {
  final StorageService _storageService = Get.find<StorageService>();

  Future<Map<String, String>> getHeaders() async {
    final token = await _storageService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<BorrowService> init() async {
    return this;
  }

  Future<void> markAsReturned(int borrowId) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/borrows/markAsReturned/$borrowId'),
        headers: await getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Erreur lors du retour de l\'emprunt: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Récupérer les demandes d'emprunt pour un propriétaire
  Future<List<Borrow>> getRequestsForOwner(String ownerEmail) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/borrows/demands/$ownerEmail'),
        headers: await getHeaders(),
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return [];
        }

        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Borrow.fromJson(json)).toList();
      } else {
        throw Exception(
          'Erreur lors de la récupération des demandes: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Accepter une demande d'emprunt
  Future<Borrow> acceptBorrowRequest(int borrowId) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/borrows/$borrowId/accept'),
        headers: await getHeaders(),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Borrow.fromJson(responseData);
      } else {
        throw Exception(
          'Erreur lors de l\'acceptation de la demande: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Refuser une demande d'emprunt
  Future<Borrow> rejectBorrowRequest(int borrowId) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/borrows/$borrowId/reject'),
        headers: await getHeaders(),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Borrow.fromJson(responseData);
      } else {
        throw Exception(
          'Erreur lors du refus de la demande: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Borrow> borrowBook(
    int bookId,
    String userEmail,
    DateTime borrowDate,
    DateTime returnDate,
  ) async {
    try {
      final Map<String, dynamic> requestBody = {
        'requestDate': DateTime.now().toIso8601String().split('T')[0],
        'responseDate': null,
        'borrowDate': borrowDate.toIso8601String().split('T')[0],
        'expectedReturnDate': returnDate.toIso8601String().split('T')[0],
        'numberOfRenewals': 0,
        'borrowStatus': 'PENDING',
        'borrower': {'email': userEmail},
        'book': {'id': bookId},
      };

      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/borrows'),
        headers: await getHeaders(),
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.body.isEmpty) {
          // Si la réponse est vide mais le statut est OK, on crée un emprunt avec les données envoyées
          return Borrow(
            requestDate: DateTime.now(),
            borrowDate: borrowDate,
            expectedReturnDate: returnDate,
            numberOfRenewals: 0,
            borrowStatus: BorrowStatus.PENDING,
            book: Book(
              id: bookId,
              title: 'Livre #$bookId',
              author: 'Auteur inconnu',
              description: 'Description non disponible',
              coverUrl: '',
              publishedDate: DateTime.now().toIso8601String().split('T')[0],
              isbn: 'N/A',
              category: 'Non catégorisé',
              pageCount: 0,
              language: 'fr',
            ),
          );
        }

        try {
          final responseData = jsonDecode(response.body);
          return Borrow.fromJson(responseData);
        } catch (e) {
          // En cas d'erreur de parsing, on retourne aussi un emprunt avec les données envoyées
          return Borrow(
            requestDate: DateTime.now(),
            borrowDate: borrowDate,
            expectedReturnDate: returnDate,
            numberOfRenewals: 0,
            borrowStatus: BorrowStatus.PENDING,
            book: Book(
              id: bookId,
              title: 'Livre #$bookId',
              author: 'Auteur inconnu',
              description: 'Description non disponible',
              coverUrl: '',
              publishedDate: DateTime.now().toIso8601String().split('T')[0],
              isbn: 'N/A',
              category: 'Non catégorisé',
              pageCount: 0,
              language: 'fr',
            ),
          );
        }
      } else {
        throw Exception(
          'Erreur lors de l\'emprunt du livre: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Borrow>> getAllBorrows() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/borrows'),
        headers: await getHeaders(),
      );
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return [];
        }

        try {
          final List<dynamic> jsonList = jsonDecode(response.body);
          return jsonList.map((json) => Borrow.fromJson(json)).toList();
        } catch (e) {
          return [];
        }
      } else {
        throw Exception(
          'Erreur lors du chargement des emprunts: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Borrow>> getBorrowDemandsByEmail(String email) async {
    http.Response? response; // Déclaration pour accès dans catch

    try {
      final headers = {
        ...await getHeaders(),
        'Accept-Charset': 'utf-8', // Ajout du charset pour la requête
      };

      final url = '${AppConfig.apiBaseUrl}/borrows/demands/$email';
      response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        if (response.bodyBytes.isEmpty) {
          return [];
        }

        try {
          final decodedBody = utf8.decode(response.bodyBytes);
          final List<dynamic> data = json.decode(decodedBody);
          final borrows = data.map((json) => Borrow.fromJson(json)).toList();
          return borrows;
        } on FormatException {
          final decodedBody = latin1.decode(response.bodyBytes);
          final List<dynamic> data = json.decode(decodedBody);
          final borrows = data.map((json) => Borrow.fromJson(json)).toList();
          return borrows;
        }
      } else {
        throw Exception(
          'Erreur lors de la récupération des demandes: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (response != null) {}
      return [];
    }
  }

  // Récupérer les emprunts d'un utilisateur
  Future<List<Borrow>> getUserBorrows(String userEmail) async {
    http.Response? response; // Pour accès en cas d'erreur

    try {
      final headers = {
        ...await getHeaders(),
        'Accept-Charset': 'utf-8', // Ajout du charset
      };

      final url = '${AppConfig.apiBaseUrl}/borrows/requests/$userEmail';

      response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        if (response.bodyBytes.isEmpty) {
          return [];
        }

        try {
          final decodedBody = utf8.decode(response.bodyBytes);
          final List<dynamic> data = json.decode(decodedBody);
          final borrows = data.map((json) => Borrow.fromJson(json)).toList();
          return borrows;
        } on FormatException {
          final decodedBody = latin1.decode(response.bodyBytes);
          final List<dynamic> data = json.decode(decodedBody);
          final borrows = data.map((json) => Borrow.fromJson(json)).toList();

          return borrows;
        }
      } else {
        throw Exception(
          'Erreur lors de la récupération des emprunts: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (response != null) {}
      return [];
    }
  }

  Future<Borrow> processBorrowRequest(Borrow borrow, bool isApproved) async {
    try {
      final response = await http.put(
        Uri.parse(
          '${AppConfig.apiBaseUrl}/borrows/approved/${isApproved.toString()}',
        ),
        headers: await getHeaders(),
        body: jsonEncode(borrow.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Borrow.fromJson(responseData);
      } else {
        throw Exception(
          'Erreur lors du traitement de la demande: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DateTime>> getOccupiedDatesByBookId(int bookId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/borrows/BookOccupiedDates/$bookId'),
        headers: await getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        List<DateTime> allDates = [];

        for (var item in jsonList) {
          DateTime fromDate = DateTime.parse(item['from']);
          DateTime toDate = DateTime.parse(item['to']);

          // Ajouter toutes les dates dans la plage
          DateTime currentDate = fromDate;
          while (currentDate.isBefore(toDate) ||
              currentDate.isAtSameMomentAs(toDate)) {
            allDates.add(
              DateTime(currentDate.year, currentDate.month, currentDate.day),
            );
            currentDate = currentDate.add(const Duration(days: 1));
          }
        }

        return allDates;
      } else {
        throw Exception(
          'Erreur lors de la récupération des dates: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<Borrow> getBorrowById(int borrowId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/borrows/$borrowId'),
        headers: await getHeaders(),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Borrow.fromJson(responseData);
      } else {
        throw Exception(
          'Erreur lors de la récupération de l\'emprunt: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelWhileInProgress(int borrowId) async {
    try {
      final response = await http.put(
        Uri.parse(
          '${AppConfig.apiBaseUrl}/borrows/cancelWhileInProgress/$borrowId',
        ),
        headers: await getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Erreur lors de l\'annulation de l\'emprunt en cours: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelPendingOrApproved(int borrowId) async {
    try {
      final response = await http.delete(
        Uri.parse(
          '${AppConfig.apiBaseUrl}/borrows/cancelPendingOrApproved/$borrowId',
        ),
        headers: await getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Erreur lors de l\'annulation de l\'emprunt en attente ou approuvé: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DateTime>> getBookOccupiedDatesUpdatedBorrow(
    int bookId,
    int borrowId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${AppConfig.apiBaseUrl}/borrows/getBookOccupiedDatesUpdatedBorrow/$bookId/$borrowId',
        ),
        headers: await getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        List<DateTime> allDates = [];

        for (var item in jsonList) {
          DateTime fromDate = DateTime.parse(item['from']);
          DateTime toDate = DateTime.parse(item['to']);

          // Ajouter toutes les dates dans la plage
          DateTime currentDate = fromDate;
          while (currentDate.isBefore(toDate) ||
              currentDate.isAtSameMomentAs(toDate)) {
            allDates.add(
              DateTime(currentDate.year, currentDate.month, currentDate.day),
            );
            currentDate = currentDate.add(const Duration(days: 1));
          }
        }

        return allDates;
      } else {
        throw Exception(
          'Erreur lors de la récupération des dates mises à jour: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<Borrow> updateBorrowWhilePending(Borrow borrow) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/borrows/updateBorrowWhilePending'),
        headers: await getHeaders(),
        body: jsonEncode(borrow.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Borrow.fromJson(responseData);
      } else {
        throw Exception(
          'Erreur lors de la mise à jour de l\'emprunt: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
