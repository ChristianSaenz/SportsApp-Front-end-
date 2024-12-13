class CourseHelper {
  static List<Map<String, String>> parseSections(String content) {
    List<String> lines = content.split('\n');
    List<Map<String, String>> sections = [];

    String currentTitle = '';
    String currentContent = '';

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (isHeading(line)) {
        if (currentTitle.isNotEmpty) {
          sections.add({'title': currentTitle, 'content': currentContent.trim()});
        }
        currentTitle = line;
        currentContent = '';
      } else {
        currentContent += '$line\n'; 
      }
    }

    if (currentTitle.isNotEmpty) {
      sections.add({'title': currentTitle, 'content': currentContent.trim()});
    }

    return sections;
  }

  static bool isHeading(String line) {
    bool isBulletPoint = line.startsWith('- ') || line.startsWith('• ');
    bool hasPunctuation = line.contains('.') || line.contains(':');
    return !isBulletPoint && !hasPunctuation && line.length < 50;
  }
}
