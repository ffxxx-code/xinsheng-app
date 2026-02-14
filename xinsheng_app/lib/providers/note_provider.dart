import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/note_model.dart';
import '../services/note_service.dart';

// Notes stream
final notesStreamProvider = StreamProvider<List<NoteModel>>((ref) {
  return NoteService.getNotesStream();
});

// User notes stream
final userNotesStreamProvider = StreamProvider.family<List<NoteModel>, String>((ref, userId) {
  return NoteService.getUserNotesStream(userId);
});

// Comments stream
final commentsStreamProvider = StreamProvider.family<List<dynamic>, String>((ref, noteId) {
  return NoteService.getCommentsStream(noteId);
});

// Liked notes
final likedNotesProvider = FutureProvider.family<List<NoteModel>, String>((ref, userId) {
  return NoteService.getLikedNotes(userId);
});

// Favorited notes
final favoritedNotesProvider = FutureProvider.family<List<NoteModel>, String>((ref, userId) {
  return NoteService.getFavoritedNotes(userId);
});

// Note by ID
final noteByIdProvider = FutureProvider.family<NoteModel?, String>((ref, noteId) {
  return NoteService.getNoteById(noteId);
});
