// // lib/complaint_screen.dart
// import 'dart:io'; // Required for handling file types from image_picker
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
// import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
// import 'package:image_picker/image_picker.dart'; // Import Image Picker
// import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth to get the user ID

// class ComplaintScreen extends StatefulWidget {
//   const ComplaintScreen({super.key});

//   @override
//   State<ComplaintScreen> createState() => _ComplaintScreenState();
// }

// class _ComplaintScreenState extends State<ComplaintScreen> {
//   final TextEditingController _complaintController = TextEditingController();

//   // New state variables for image attachment
//   final ImagePicker _picker = ImagePicker();
//   XFile? _imageFile; // Stores the selected image file
//   bool _isUploading = false; // To show a loading indicator during upload

//   // Function to handle image selection from the gallery
//   Future<void> _pickImage() async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//       if (pickedFile != null) {
//         setState(() {
//           _imageFile = pickedFile;
//         });
//         // // // // print('DEBUG (Image Picker): Image selected: ${pickedFile.path}');
//       } else {
//         // // // // print('DEBUG (Image Picker): No image selected by user.');
//       }
//     } catch (e) {
//       // // // // print('ERROR (Image Picker): Failed to pick image: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to pick image: $e')),
//       );
//     }
//   }

//   // This is the core function that sends the data to Firestore!
//   Future<void> _sendComplaint() async {
//     // // // // print('DEBUG (Send Complaint): Entered _sendComplaint function.'); // ADDED THIS

//     final User? user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       // // // // print('DEBUG (Send Complaint): No user signed in. Complaint will be sent anonymously.');
//       // Important: For production apps, you'd likely want to enforce user login
//       // or at least handle anonymous users more robustly.
//     } else {
//       // // // // print('DEBUG (Send Complaint): User signed in: ${user.uid}');
//     }

//     // --- Check for empty complaint/image ---
//     if (_complaintController.text.isEmpty && _imageFile == null) {
//       // // // // print('DEBUG (Send Complaint): Complaint text and image are both empty. Returning early.');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter your complaint or attach an image before sending!'),
//         ),
//       );
//       // It's important to reset _isUploading if we return early
//       if (mounted) { // Check if the widget is still mounted before setState
//         setState(() {
//           _isUploading = false;
//         });
//       }
//       return; // Stop the function here
//     }

//     // Set uploading state to true to show a loading indicator
//     if (mounted) { // Check if the widget is still mounted before setState
//       setState(() {
//         _isUploading = true;
//       });
//     }

//     String? imageUrl;

//     try {
//       // // // // print('DEBUG (Send Complaint): Starting image upload process (if image selected).');
//       // 1. UPLOAD IMAGE TO FIREBASE STORAGE (if an image was selected)
//       if (_imageFile != null) {
//         final file = File(_imageFile!.path);
//         // Create a unique file path in Firebase Storage
//         final storageRef = FirebaseStorage.instance
//             .ref()
//             .child('complaint_attachments/${user?.uid ?? 'anonymous'}/${DateTime.now().millisecondsSinceEpoch}_${_imageFile!.name}');

//         // // // // print('DEBUG (Storage): Attempting to upload image to Storage path: ${storageRef.fullPath}');
//         // Upload the file
//         final uploadTask = storageRef.putFile(file);
//         final snapshot = await uploadTask.whenComplete(() {}); // Wait for upload completion

//         // Get the download URL for the uploaded image
//         imageUrl = await snapshot.ref.getDownloadURL();
//         // // // // print('DEBUG (Storage): Image uploaded to Firebase Storage. URL: $imageUrl');
//       } else {
//         // // // // print('DEBUG (Storage): No image selected, skipping Firebase Storage upload.');
//       }

//       // // // // print('DEBUG (Firestore): Proceeding to save data to Cloud Firestore.'); // ADDED THIS

//       // 2. SAVE DATA TO CLOUD FIRESTORE
//       FirebaseFirestore firestore = FirebaseFirestore.instance;

//       // // // // print('DEBUG (Firestore): Attempting to add main complaint document to "complaints" collection...');
//       // First, add the main complaint
//       DocumentReference complaintRef = await firestore.collection('complaints').add({
//         'text': _complaintController.text,
//         'imageUrl': imageUrl, // This will be null if no image was attached
//         'timestamp': FieldValue.serverTimestamp(),
//         'status': 'Unresolved',
//         'user_id': user?.uid ?? 'anonymous',
//       });
//       // // // // print('DEBUG (Firestore): Main complaint document added with ID: ${complaintRef.id}');

//       // // // // print('DEBUG (Firestore): Attempting to add initial message to "messages" subcollection under complaint ID: ${complaintRef.id}...');
//       // Then, create a subcollection called "messages" under this complaint
//       await complaintRef.collection('messages').add({
//         'message': _complaintController.text, // CHANGED 'text' to 'message' for consistency with admin panel
//         'timestamp': FieldValue.serverTimestamp(),
//         'sender': 'user', // could be 'user' or 'admin'
//       });
//       // // // // print('DEBUG (Firestore): Initial message added to subcollection successfully!');

//       // Clear the text field and reset the image file after successful submission
//       _complaintController.clear();
//       if (mounted) {
//         setState(() {
//           _imageFile = null;
//         });
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Complaint sent successfully!')),
//       );

//       // // // // // print('DEBUG (Send Complaint): Complaint successfully added to Firestore (main document and subcollection)!'); // ADDED THIS
//     } catch (e) {
//       // Catch and // // // // print any errors during the process
//       // // // // print('ERROR (Send Complaint): An error occurred during complaint submission or subcollection creation: $e'); // MADE DISTINCT
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Failed to send complaint: $e')));
//     } finally {
//       // Always reset the uploading state, even if an error occurred
//       if (mounted) {
//         setState(() {
//           _isUploading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Submit a Complaint'),
//         backgroundColor: Colors.blueAccent,
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const Text(
//               'Please enter your complaint below:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _complaintController,
//               decoration: const InputDecoration(
//                 labelText: 'Type your complaint here...',
//                 hintText: 'e.g., My internet is down, customer service was rude, etc.',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                 ),
//                 alignLabelWithHint: true,
//               ),
//               maxLines: 6,  
//               keyboardType: TextInputType.multiline,
//             ),
//             const SizedBox(height: 15),

//             // NEW: Row for image attachment and button
//             Row(
//               children: [
//                 // Display the selected image thumbnail
//                 if (_imageFile != null)
//                   Padding(
//                     padding: const EdgeInsets.only(right: 15.0),
//                     child: Stack(
//                       children: [
//                         SizedBox(
//                           height: 80,
//                           width: 80,
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(10.0),
//                             child: Image.file(
//                               File(_imageFile!.path),
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                         Positioned(
//                           right: 0,
//                           child: GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 _imageFile = null; // Remove the selected image
//                               });
//                             },
//                             child: const Icon(Icons.cancel, color: Colors.red),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: _isUploading ? null : _pickImage,
//                     icon: const Icon(Icons.attach_file),
//                     label: const Text('Attach an Image'),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 15),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 25),

//             ElevatedButton(
//               onPressed: _isUploading ? null : _sendComplaint,
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 15),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 backgroundColor: Colors.deepOrange,
//                 foregroundColor: Colors.white,
//               ),
//               child: _isUploading
//                   ? const CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     )
//                   : const Text(
//                       'Send Complaint',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _complaintController.dispose();
//     super.dispose();
//   }
// }

