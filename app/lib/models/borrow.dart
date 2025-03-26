import 'package:app/models/book.dart';
import 'package:app/models/user_model.dart';
import 'package:app/enums/borrow_status.dart';

class Borrow {
  final int? id;
  final DateTime? requestDate;
  final DateTime? responseDate;
  final DateTime? borrowDate;
  final DateTime? expectedReturnDate;
  final int numberOfRenewals;
  final BorrowStatus borrowStatus;
  final User? borrower;
  final Book? book;

  Borrow({
    this.id,
    this.requestDate,
    this.responseDate,
    this.borrowDate,
    this.expectedReturnDate,
    this.numberOfRenewals = 0,
    this.borrowStatus = BorrowStatus.PENDING,
    this.borrower,
    this.book,
  });

  factory Borrow.fromJson(Map<String, dynamic> json) {
    return Borrow(
      id: json['id'],
      requestDate: json['requestDate'] != null ? DateTime.parse(json['requestDate']) : null,
      responseDate: json['responseDate'] != null ? DateTime.parse(json['responseDate']) : null,
      borrowDate: json['borrowDate'] != null ? DateTime.parse(json['borrowDate']) : null,
      expectedReturnDate: json['expectedReturnDate'] != null ? DateTime.parse(json['expectedReturnDate']) : null,
      numberOfRenewals: json['numberOfRenewals'] ?? 0,
      borrowStatus: _parseBorrowStatus(json['borrowStatus']),
      borrower: json['borrower'] != null ? User.fromJson(json['borrower']) : null,
      book: json['book'] != null ? Book.fromJson(json['book']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestDate': requestDate?.toIso8601String(),
      'responseDate': responseDate?.toIso8601String(),
      'borrowDate': borrowDate?.toIso8601String(),
      'expectedReturnDate': expectedReturnDate?.toIso8601String(),
      'numberOfRenewals': numberOfRenewals,
      'borrowStatus': borrowStatus.toString().split('.').last,
      'borrower': borrower?.toJson(),
      'book': book?.toJson(),
    };
  }

  static BorrowStatus _parseBorrowStatus(String? status) {
    if (status == null) return BorrowStatus.PENDING;
    
    switch (status.toUpperCase()) {
      case 'ACCEPTED':
        return BorrowStatus.ACCEPTED;
      case 'REJECTED':
        return BorrowStatus.REJECTED;
      case 'RETURNED':
        return BorrowStatus.RETURNED;
      case 'PENDING':
      default:
        return BorrowStatus.PENDING;
    }
  }
}
