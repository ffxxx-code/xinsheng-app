import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/message_model.dart';
import '../services/message_service.dart';

// Messages stream
final messagesStreamProvider = StreamProvider.family<List<MessageModel>, String>((ref, userId) {
  return MessageService.getMessagesStream(userId);
});

// Unread count stream
final unreadCountStreamProvider = StreamProvider.family<int, String>((ref, userId) {
  return MessageService.getUnreadCountStream(userId);
});
