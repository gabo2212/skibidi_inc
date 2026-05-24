class AppUser {
  const AppUser({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.role,
    required this.groups,
  });

  final String userId;
  final String email;
  final String displayName;
  final String role;
  final List<String> groups;

  bool get isAdmin => role == 'admin';
  bool get isInstructor => role == 'admin' || role == 'instructor';
  bool get isIntern => role == 'intern';

  factory AppUser.preview(String email) {
    final lower = email.toLowerCase();
    final role = lower.contains('admin')
        ? 'admin'
        : lower.contains('instructor')
        ? 'instructor'
        : 'intern';
    return AppUser(
      userId: lower,
      email: email,
      displayName: email.split('@').first,
      role: role,
      groups: <String>[role],
    );
  }
}
