import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();

  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contact Support")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Please fill the form below*"),
              const SizedBox(height: 10),
              TextFormField(
                controller: _messageController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Enter your issue here...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 20),
              _isUploading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(150, 50),
                            backgroundColor: const Color.fromARGB(
                              255,
                              255,
                              77,
                              0,
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isUploading = true;
                              });

                              try {
                                final userEmail =
                                    FirebaseAuth.instance.currentUser?.email;

                                DocumentReference complaintRef =
                                    await FirebaseFirestore.instance
                                        .collection('complaints')
                                        .add({
                                          "text": _messageController.text,
                                          "status": "Unresolved",
                                          "timestamp": Timestamp.now(),
                                          "user_id":
                                              userEmail ?? "unknown@email.com",
                                        });

                                await complaintRef.collection('messages').add({
                                  'message': _messageController
                                      .text, // CHANGED 'text' to 'message' for consistency with admin panel
                                  'timestamp': FieldValue.serverTimestamp(),
                                  'sender':
                                      'user', // could be 'user' or 'admin'
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Complaint submitted successfully!",
                                    ),
                                  ),
                                );

                                _messageController.clear();
                                Navigator.pop(context);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Error submitting complaint: $e",
                                    ),
                                  ),
                                );
                              } finally {
                                setState(() {
                                  _isUploading = false;
                                });
                              }
                            }
                          },
                          child: const Text(
                            "Submit",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
