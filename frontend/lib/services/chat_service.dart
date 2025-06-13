import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Chat {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final Timestamp? updatedAt;

  Chat({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.updatedAt,
  });

  factory Chat.fromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;

    // Safe-cast updatedAt
    final rawUpdated = data['updatedAt'];
    final Timestamp? updatedAt = rawUpdated is Timestamp ? rawUpdated : null;

    return Chat(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'] as String?,
      updatedAt: updatedAt,
    );
  }
}

class Message {
  final String id;
  final String senderId;
  final String text;
  final Timestamp timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  factory Message.fromDoc(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;
    // If Firestore hasn't yet set the serverTimestamp, use now()
    final rawTs = d['timestamp'];
    final ts = rawTs is Timestamp ? rawTs : Timestamp.now();

    return Message(
      id: doc.id,
      senderId: d['senderId'] as String,
      text: d['text'] as String,
      timestamp: ts,
    );
  }
}

class ChatService {
  final _dio;
  ChatService(this._dio);
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String _makeChatId(String a, String b) {
    final sorted = [a, b]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  /// Stream of all chats for current user
  Stream<List<Chat>> watchChats() {
    final uid = _auth.currentUser!.uid;
    return _db
        .collection('chats')
        .where('participants', arrayContains: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Chat.fromDoc).toList());
  }

  /// Stream of messages in one chat
  Stream<List<Message>> watchMessages(String chatId) {
    return _db
        .collection('chats/$chatId/messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snap) => snap.docs.map(Message.fromDoc).toList());
  }

  /// Ensure chat doc exists and return its ID
  Future<String> createOrGetChat(String otherUid) async {
    final me = _auth.currentUser!.uid;
    final chatId = _makeChatId(me, otherUid);
    final ref = _db.collection('chats').doc(chatId);
    await ref.set({
      'participants': [me, otherUid],
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return chatId;
  }

  /// Send a message
  Future<void> sendMessage(String chatId, String text) async {
    final me = _auth.currentUser!.uid;

    // 1) write the Firestore message
    await _db.collection('chats/$chatId/messages').add({
      'senderId': me,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2) bump the metadata (optional if you rely on Cloud Function)
    await _db.doc('chats/$chatId').update({
      'lastMessage': text,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 3) notify the other participant via your backend
    final participants = chatId.split('_'); // your deterministic ID
    final other = participants.firstWhere((u) => u != me);
    await _dio.post(
      '/notifications/chat',
      data: {
        'chatId': chatId,
        'senderId': me,
        'text': text,
        'recipients': [other],
      },
    );
  }
}
