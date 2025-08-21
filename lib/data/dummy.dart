// lib/data/dummy.dart
import 'package:ui_customer/model/ticket_model.dart';

final List<TicketModel> dummyTickets = [
  TicketModel(
    id: 1,
    status: "Pending",
    message: "Internet connection is unstable",
    email: "user1@example.com",
    date: DateTime.now().subtract(const Duration(days: 1)),
  ),
  TicketModel(
    id: 2,
    status: "Resolved",
    message: "Router issue fixed successfully",
    email: "user2@example.com",
    date: DateTime.now().subtract(const Duration(days: 3)),
  ),
  TicketModel(
    id: 3,
    status: "Unresolved",
    message: "Frequent disconnection during calls",
    email: "user3@example.com",
    date: DateTime.now().subtract(const Duration(days: 5)),
  ),
];
