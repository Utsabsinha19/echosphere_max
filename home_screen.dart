import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../services/wallet_service.dart';
import '../services/ai_service.dart';
import '../utils/theme_service.dart';
import '../models/post_model.dart';
import '../constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Post> _publicPosts = [];
  List<Post> _privatePosts = [];
  bool _isLoading = true;
  final Set<String> _viewedPosts = {};
  final List<ScrollController> _scrollControllers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final aiService = Provider.of<AIService>(context, listen: false);
    final walletService = Provider.of<WalletService>(context, listen: false);
    
    try {
      setState(() => _isLoading = true);
      
      // Load public posts (would be from blockchain in production)
      _publicPosts = await aiService.getPublicPosts();
      
      // Load personalized private feed
      _privatePosts = await aiService.getPersonalizedFeed(
        walletService.currentAddress?.hex ?? ''
      );
      
    } catch (e) {
      debugPrint('Error loading posts: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('EchoSphere'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () => themeService.toggleTheme(),
          ),
          IconButton(
            icon: FaIcon(themeService.is3DMode 
              ? FontAwesomeIcons.cube 
              : FontAwesomeIcons.solidSquare
            ),
            onPressed: () => themeService.toggle3DMode(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Public Feed'),
            Tab(text: 'Private Feed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeed(_publicPosts, isPublic: true),
          _buildFeed(_privatePosts, isPublic: false),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFeed(List<Post> posts, {required bool isPublic}) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
    final scrollController = ScrollController();
    _scrollControllers.add(scrollController);

    // Track when posts become visible
    scrollController.addListener(() {
      final position = scrollController.position;
      if (position.pixels >= position.maxScrollExtent * 0.9) {
        // When scrolled near bottom, track view for last few posts
        final startIndex = posts.length > 5 ? posts.length - 5 : 0;
        for (int i = startIndex; i < posts.length; i++) {
          if (!_viewedPosts.contains(posts[i].id)) {
            analyticsService.trackView(posts[i].id);
            setState(() {
              posts[i].viewCount++;
              _viewedPosts.add(posts[i].id);
            });
          }
        }
      }
    });

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          elevation: Provider.of<ThemeService>(context).is3DMode ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.content,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                if (post.summary != null)
                  Text(
                    'AI Summary: ${post.summary}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.remove_red_eye, size: 16),
                        const SizedBox(width: 4),
                        Text('${post.viewCount}'),
                        const SizedBox(width: 8),
                        const Icon(Icons.favorite_border, size: 16),
                        const SizedBox(width: 4),
                        Text('${post.likeCount}'),
                        const SizedBox(width: 8),
                        const Icon(Icons.share, size: 16),
                        const SizedBox(width: 4),
                        Text('${post.shareCount}'),
                        const SizedBox(width: 8),
                        const Icon(Icons.comment, size: 16),
                        const SizedBox(width: 4),
                        Text('${post.commentCount}'),
                      ],
                    ),
                if (post.isAR)
                  IconButton(
                    icon: const Icon(Icons.view_in_ar),
                    onPressed: () => _viewARPost(post),
                  ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.share),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'share',
                      child: Text('Share Post'),
                    ),
                    const PopupMenuItem(
                      value: 'blog',
                      child: Text('Share as Blog Post'),
                    ),
                    const PopupMenuItem(
                      value: 'platforms',
                      child: Text('Share to Specific Platform'),
                    ),
                  ],
                  onSelected: (value) => _handleShareOption(value, post),
                ),
                IconButton(
                  icon: const Icon(Icons.voice_chat),
                  onPressed: () => _startVoiceReply(post.id),
                ),
                    const Spacer(),
                    Text(
                      '${post.emotionScore}% ${post.emotionType}',
                      style: TextStyle(
                        color: _getEmotionColor(post.emotionType),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getEmotionColor(String emotion) {
    return AppConstants.moodColors[emotion.toLowerCase()] ?? Colors.grey;
  }

  void _showCreatePostDialog() async {
    final newPost = await Navigator.of(context).push<Post>(
      MaterialPageRoute(builder: (_) => const CreatePostScreen()),
    );
    
    if (newPost != null && mounted) {
      setState(() {
        _publicPosts.insert(0, newPost);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );
    }
  }

  void _viewARPost(Post post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ARViewScreen(post: post),
      ),
    );
  }

  Future<void> _handleShareOption(String option, Post post) async {
    final sharingService = SharingService(Provider.of<AIService>(context, listen: false));
    try {
      switch (option) {
        case 'share':
          await sharingService.sharePost(post);
          break;
        case 'blog':
          await sharingService.shareAsBlogPost(post);
          break;
        case 'platforms':
          _showPlatformSelection(post);
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share: $e')),
      );
    }
  }

  void _showPlatformSelection(Post post) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.facebook),
            title: const Text('Facebook'),
            onTap: () {
              Navigator.pop(context);
              _shareToSpecificPlatform('Facebook', post);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Instagram'),
            onTap: () {
              Navigator.pop(context);
              _shareToSpecificPlatform('Instagram', post);
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Twitter'),
            onTap: () {
              Navigator.pop(context);
              _shareToSpecificPlatform('Twitter', post);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _shareToSpecificPlatform(String platform, Post post) async {
    final sharingService = SharingService(Provider.of<AIService>(context, listen: false));
    try {
      await sharingService.shareToPlatform(platform, post);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share to $platform: $e')),
      );
    }
  }

  void _startVoiceReply(String postId) async {
    final voiceService = VoiceService();
    await voiceService.init();

    await voiceService.startRecording();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recording...')),
    );

    // Wait for a moment to simulate recording duration
    await Future.delayed(const Duration(seconds: 5));

    final recordingPath = await voiceService.stopRecording();
    if (recordingPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recording stopped!')),
      );

      // Here you can handle the recorded audio (e.g., upload, play back)
      await voiceService.playRecording(recordingPath);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
