import 'package:flutter/material.dart';
import 'package:ui_customer/screen/chat/chat.dart';
import 'package:ui_customer/screen/home/widgets/ticket_card.dart';
import 'package:ui_customer/data/dummy.dart';
import 'package:ui_customer/model/ticket_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Tickets")),
      body: ListView.builder(
        itemCount: dummyTickets.length,
        itemBuilder: (context, index) {
          final TicketModel ticket = dummyTickets[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(ticketId: ticket.id),
                ),
              );
            },
            child: TicketCard(
              id: ticket.id,
              status: ticket.status,
              message: ticket.message,
              email: ticket.email,
              date: ticket.date,
            ),
          );
        },
      ),
    );
  }
}
