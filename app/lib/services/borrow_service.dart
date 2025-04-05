import 'dart:convert';
import 'package:app/models/borrow.dart';
import 'package:app/models/book.dart';
import 'package:app/enums/borrow_status.dart';
import 'package:app/services/storage_service.dart';
import 'package:app/models/user_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class BorrowService extends GetxService {
  final StorageService _storageService = Get.find<StorageService>();
  static const String baseUrl = 'http://10.0.2.2:8080';

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

  // Récupérer les demandes d'emprunt pour un propriétaire
  Future<List<Borrow>> getRequestsForOwner(String ownerEmail) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/borrows/demands/$ownerEmail'),
        headers: await getHeaders(),
      );

      print(
        'getRequestsForOwner response: ${response.statusCode} - ${response.body}',
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
      print('getRequestsForOwner error: $e');
      rethrow;
    }
  }

  // Accepter une demande d'emprunt
  Future<Borrow> acceptBorrowRequest(int borrowId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/borrows/$borrowId/accept'),
        headers: await getHeaders(),
      );

      print(
        'acceptBorrowRequest response: ${response.statusCode} - ${response.body}',
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
      print('acceptBorrowRequest error: $e');
      rethrow;
    }
  }

  // Refuser une demande d'emprunt
  Future<Borrow> rejectBorrowRequest(int borrowId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/borrows/$borrowId/reject'),
        headers: await getHeaders(),
      );

      print(
        'rejectBorrowRequest response: ${response.statusCode} - ${response.body}',
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
      print('rejectBorrowRequest error: $e');
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

      print('Sending borrow request: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/borrows'),
        headers: await getHeaders(),
        body: jsonEncode(requestBody),
      );

      print('borrowBook response: ${response.statusCode} - ${response.body}');

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
          print('Error parsing JSON response: $e');
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
      print('borrowBook error: $e');
      rethrow;
    }
  }

  Future<List<Borrow>> getAllBorrows() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/borrows'),
        headers: await getHeaders(),
      );

      print(
        'getAllBorrows response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return [];
        }

        try {
          final List<dynamic> jsonList = jsonDecode(response.body);
          return jsonList.map((json) => Borrow.fromJson(json)).toList();
        } catch (e) {
          print('Error parsing JSON response: $e');
          return [];
        }
      } else {
        throw Exception(
          'Erreur lors du chargement des emprunts: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('getAllBorrows error: $e');
      rethrow;
    }
  }

  Future<List<Borrow>> getBorrowDemandsByEmail(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/borrows/demands/$email'),
        headers: await getHeaders(),
      );

      print(
        'getBorrowDemandsByEmail response: ${response.statusCode} - ${response.body}',
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
      print('getBorrowDemandsByEmail error: $e');
      rethrow;
    }
  }

  // Récupérer les emprunts d'un utilisateur
  Future<List<Borrow>> getUserBorrows(String userEmail) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/borrows/requests/$userEmail'),
        headers: await getHeaders(),
      );

      print(
        'getUserBorrows response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return [];
        }

        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Borrow.fromJson(json)).toList();
      } else {
        throw Exception(
          'Erreur lors de la récupération des emprunts: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('getUserBorrows error: $e');
      rethrow;
    }
  }

  Future<Borrow> processBorrowRequest(Borrow borrow, bool isApproved) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/borrows/approved/${isApproved.toString()}'),
        headers: await getHeaders(),
        body: jsonEncode(borrow.toJson()),
      );

      print(
        'processBorrowRequest response: ${response.statusCode} - ${response.body}',
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
      print('processBorrowRequest error: $e');
      rethrow;
    }
  }

  Future<List<DateTime>> getOccupiedDatesByBookId(int bookId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/borrows/BookOccupiedDates/$bookId'),
        headers: await getHeaders(),
      );

      print(
        'getOccupiedDatesByBookId response: ${response.statusCode} - ${response.body}',
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
      print('getOccupiedDatesByBookId error: $e');
      throw Exception('Erreur réseau: $e');
    }
  }
}
