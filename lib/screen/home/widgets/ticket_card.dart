import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String ticketNo;

  const ChatScreen({required this.ticketNo, super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _showStatusMenu = false;
  final TextEditingController _controller = TextEditingController();

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('complaints')
        .doc(widget.ticketNo)
        .collection('messages')
        .add({
          'message': text,
          'sender': 'admin',
          'timestamp': FieldValue.serverTimestamp(),
        });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Ticket No. ${widget.ticketNo}"),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              setState(() {
                _showStatusMenu = !_showStatusMenu;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('complaints')
                      .doc(widget.ticketNo)
                      .collection('messages')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final message = docs[index];
                        final data = message.data() as Map<String, dynamic>;

                        final String senderType =
                            data['sender'] as String? ?? 'user';

                        final bool isMessageFromAdmin = (senderType == 'admin');

                        return Align(
                          alignment: isMessageFromAdmin
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            // ======== THIS IS THE CHANGE! ========
                            padding: const EdgeInsets.all(
                              16,
                            ), // Increased from 12 to 16
                            // =====================================
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isMessageFromAdmin
                                  ? Colors.green
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              
                              data['message'] ?? '',
                              style: TextStyle(
                                fontSize: 26,
                                color: isMessageFromAdmin
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Input field
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Type your reply...',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
