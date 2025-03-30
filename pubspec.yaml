import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../models/post_model.dart';
import '../services/ai_service.dart';

class SharingService {
  final AIService _aiService;

  SharingService(this._aiService);

  Future<void> sharePost(Post post) async {
    try {
      final text = '${post.content}\n\nShared from EchoSphere';
      await Share.share(text);
    } catch (e) {
      throw Exception('Failed to share post: $e');
    }
  }

  Future<void> shareAsBlogPost(Post post) async {
    try {
      final blogContent = await _aiService.convertToBlogPost(post.content);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/blog_post_${post.id}.txt');
      await file.writeAsString(blogContent);
      await Share.shareFiles([file.path], text: 'Blog post version of my EchoSphere post');
    } catch (e) {
      throw Exception('Failed to share as blog post: $e');
    }
  }

  Future<void> shareToPlatform(String platform, Post post) async {
    // Platform-specific sharing logic would go here
    // This is a placeholder for actual platform integration
    await Share.share('Sharing to $platform: ${post.content}');
  }
}
