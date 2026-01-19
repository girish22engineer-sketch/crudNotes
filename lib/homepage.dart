import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crudnotes/services/firestore.dart';
import 'package:flutter/material.dart';
class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  final FirestoreService firestoreService =FirestoreService();
  final TextEditingController textEditingController =TextEditingController();
  void openNoteBox(String? docID,{String?currentText}) {
    if(currentText!=null){
      textEditingController.text=currentText;
    }
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: TextField(
        controller: textEditingController, // ✅ use the existing controller
        decoration: const InputDecoration(hintText: "Enter note"),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (docID==null) {
              firestoreService.addNote(textEditingController.text);
              
            }else
            {
              firestoreService.updateNote(docID, textEditingController.text);
            }
            textEditingController.clear();

            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}


          @override
           Widget build(BuildContext context) {
              return Scaffold(backgroundColor: Colors.blue[80],
            appBar: AppBar(title: Text('Notes'),backgroundColor: Colors.blue[500]
             ),floatingActionButton: FloatingActionButton(
             onPressed: ()=>openNoteBox(null), // ✅ call the method
                child: const Icon(Icons.add,),
          ),

     
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData){
            List notesList = snapshot.data!.docs;
            return ListView.builder(
             itemCount: notesList.length,
             itemBuilder: (context, index) {
          DocumentSnapshot document = notesList[index]; // ✅ FIXED
             String docID = document.id;

            Map<String, dynamic> data =
            document.data() as Map<String, dynamic>;

              String noteText = data['name']; // ✅ you stored 'name'

                   return ListTile(
                  title: Text(noteText),

                   trailing:Row(mainAxisSize: MainAxisSize.min,
                    children: [
                   IconButton(onPressed: () => openNoteBox(docID, currentText: noteText),

                    icon: Icon(Icons.settings)
                    
                    ),IconButton(onPressed:() => firestoreService.deleteNote(docID) , icon: Icon(Icons.delete))
                   ],) 
                );
                 },
                    );

          }
          else {
            return Text('no notes..');
          }
        }
      ),
    );
  }
}