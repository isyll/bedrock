abstract final class AppRoutes {
  static const home = '/';
  static const signIn = '/sign-in';
  static const settings = '/settings';
  static const about = '/settings/about';

  static const publicPaths = <String>{signIn};

  static bool isPublic(String location) {
    final path = Uri.parse(location).path;
    return publicPaths.contains(path);
  }
}
