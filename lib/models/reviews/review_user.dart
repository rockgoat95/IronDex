class ReviewUser {
  const ReviewUser({required this.username});

  factory ReviewUser.fromMap(Map<String, dynamic> map) {
    return ReviewUser(username: map['username']?.toString() ?? '');
  }

  final String username;

  Map<String, dynamic> toJson() => <String, dynamic>{'username': username};
}
