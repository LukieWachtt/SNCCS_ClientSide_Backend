// lib/model/ticket_model.dart
class TicketModel {
  final int id;
  final String status;
  final String message;
  final String email;
  final DateTime date;

  TicketModel({
    required this.id,
    required this.status,
    required this.message,
    required this.email,
    required this.date,
  });
}
