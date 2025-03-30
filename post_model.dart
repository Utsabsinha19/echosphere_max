class Post {
  final String id;
  final String content;
  final String author;
  final DateTime timestamp;
  final String? summary;
  final String emotionType;
  final int emotionScore;
  final bool isAR;
  final String? imageUrl;
  final String? arContentUrl;
  BigInt tipAmount;
  int tipCount;
  int viewCount;
  int likeCount;
  int shareCount;
  int commentCount;

  Post({
    this.viewCount = 0,
    this.likeCount = 0,
    this.shareCount = 0,
    this.commentCount = 0,
    required this.id,
    required this.content,
    required this.author,
    required this.timestamp,
    this.summary,
    this.emotionType = 'neutral',
    this.emotionScore = 50,
    this.isAR = false,
    this.imageUrl,
    this.arContentUrl,
    this.tipAmount = BigInt.zero,
    this.tipCount = 0,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      content: json['content'],
      author: json['author'],
      timestamp: DateTime.parse(json['timestamp']),
      summary: json['summary'],
      emotionType: json['emotionType'] ?? 'neutral',
      emotionScore: json['emotionScore'] ?? 50,
      isAR: json['isAR'] ?? false,
      imageUrl: json['imageUrl'],
      arContentUrl: json['arContentUrl'],
      tipAmount: json['tipAmount'] != null ? BigInt.parse(json['tipAmount']) : BigInt.zero,
      tipCount: json['tipCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      shareCount: json['shareCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'author': author,
    'timestamp': timestamp.toIso8601String(),
    'summary': summary,
    'emotionType': emotionType,
    'emotionScore': emotionScore,
      'isAR': isAR,
      'imageUrl': imageUrl,
      'arContentUrl': arContentUrl,
      'tipAmount': tipAmount.toString(),
      'tipCount': tipCount,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'shareCount': shareCount,
      'commentCount': commentCount,
  };
}
