import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../services/note_service.dart';
import '../services/auth_service.dart';
import '../widgets/note_card.dart';

class MyFavoritesScreen extends ConsumerWidget {
  const MyFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('请先登录')),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('赞过与收藏'),
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: '赞过'),
              Tab(text: '收藏'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLikedNotes(context, user.id),
            _buildFavoritedNotes(context, user.id),
          ],
        ),
      ),
    );
  }

  Widget _buildLikedNotes(BuildContext context, String userId) {
    return FutureBuilder(
      future: NoteService.getLikedNotes(userId),
      builder: (context, snapshot) {
        final notes = snapshot.data ?? [];

        if (notes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('还没有赞过的动态', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return FutureBuilder(
              future: AuthService.getUserById(note.authorId),
              builder: (context, snapshot) {
                final author = snapshot.data;
                return NoteCard(
                  note: note,
                  author: author,
                  currentUserId: userId,
                  onLike: () => NoteService.likeNote(note.id, userId),
                  onComment: () => context.push('/note/${note.id}?return=/my-favorites'),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFavoritedNotes(BuildContext context, String userId) {
    return FutureBuilder(
      future: NoteService.getFavoritedNotes(userId),
      builder: (context, snapshot) {
        final notes = snapshot.data ?? [];

        if (notes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('还没有收藏的动态', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return FutureBuilder(
              future: AuthService.getUserById(note.authorId),
              builder: (context, snapshot) {
                final author = snapshot.data;
                return NoteCard(
                  note: note,
                  author: author,
                  currentUserId: userId,
                  onLike: () => NoteService.likeNote(note.id, userId),
                  onComment: () => context.push('/note/${note.id}?return=/my-favorites'),
                );
              },
            );
          },
        );
      },
    );
  }
}
