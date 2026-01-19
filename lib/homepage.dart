import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:crudnotes/services/firestore.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textEditingController =
      TextEditingController();

  // ------------------ ADD / UPDATE NOTE DIALOG ------------------
  void openNoteBox(String? docID, {String? currentText}) {
    if (currentText != null) {
      textEditingController.text = currentText;
    }

    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SizedBox(
            width: screenWidth * 0.85, // responsive dialog
            child: TextField(
              controller: textEditingController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Enter note",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (docID == null) {
                  firestoreService
                      .addNote(textEditingController.text);
                } else {
                  firestoreService.updateNote(
                    docID,
                    textEditingController.text,
                  );
                }

                textEditingController.clear();
                Navigator.pop(context);
              },
              child: Text(docID == null ? "Add" : "Update"),
            ),
          ],
        );
      },
    );
  }

  // ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: Colors.blue.shade50,

      appBar: AppBar(
        title: const Text("Notes"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade500,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => openNoteBox(null),
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: 10,
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getNotesStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Something went wrong"),
              );
            }

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData ||
                snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "No notes available",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            List notesList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = notesList[index];
                String docID = document.id;

                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;

                String noteText = data['name'];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                    title: Text(
                      noteText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => openNoteBox(
                            docID,
                            currentText: noteText,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              firestoreService.deleteNote(docID),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
