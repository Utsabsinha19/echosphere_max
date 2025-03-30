import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:provider/provider.dart';

import '../models/post_model.dart';
import '../services/ai_service.dart';
import '../utils/theme_service.dart';

class ARViewScreen extends StatefulWidget {
  final Post post;

  const ARViewScreen({super.key, required this.post});

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  late ARKitController arkitController;
  bool _isLoading = true;

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('AR View: ${widget.post.content.substring(0, 15)}...'),
      ),
      body: Stack(
        children: [
          ARKitSceneView(
            onARKitViewCreated: _onARKitViewCreated,
            enableTapRecognizer: true,
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: themeService.primaryColor,
              ),
            ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black54,
              child: Text(
                widget.post.content,
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onARKitViewCreated(ARKitController controller) {
    arkitController = controller;
    _loadARContent();
  }

  Future<void> _loadARContent() async {
    try {
      // In a real app, this would load from IPFS/blockchain
      await Future.delayed(const Duration(seconds: 1)); // Simulate loading
      
      // Add AR nodes based on post content
      final node = ARKitNode(
        geometry: ARKitText(
          text: widget.post.content,
          extrusionDepth: 1,
          materials: [
            ARKitMaterial(
              diffuse: ARKitMaterialProperty.color(Colors.blue),
            ),
          ],
        ),
        position: ARKitVector3(0, -0.5, -1),
      );
      
      arkitController.add(node);
    } catch (e) {
      debugPrint('AR loading error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
