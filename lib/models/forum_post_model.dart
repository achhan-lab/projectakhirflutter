class ForumPostModel {
  final int? id;
  final int userId;
  final String content;
  final String kategori;
  final int likes;
  final int comments;
  final String? createdAt;

  ForumPostModel({
    this.id,
    required this.userId,
    required this.content,
    required this.kategori,
    this.likes = 0,
    this.comments = 0,
    this.createdAt,
  });

  factory ForumPostModel.fromMap(Map<String, dynamic> m) => ForumPostModel(
        id: m['id'] as int?,
        userId: m['user_id'] as int? ?? 0,
        content: m['content'] as String? ?? '',
        kategori: m['kategori'] as String? ?? 'Diskusi',
        likes: m['likes'] as int? ?? 0,
        comments: m['comments'] as int? ?? 0,
        createdAt: m['created_at'] as String?,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'user_id': userId,
        'content': content,
        'kategori': kategori,
        'likes': likes,
        'comments': comments,
        'created_at': createdAt,
      };
}
