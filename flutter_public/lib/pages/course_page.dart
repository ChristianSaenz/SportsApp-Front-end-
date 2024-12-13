import 'package:flutter/material.dart';
import 'package:sport_app/handlers/api_handler.dart';
import 'package:sport_app/handlers/course_handler.dart';

class CoursePage extends StatelessWidget {
  final int sportId;
  final String sportName;

   CoursePage({
    Key? key, 
    required this.sportId,
    required this.sportName,
  }) : super(key: key);

  final ApiHandler apiHandler = ApiHandler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Info for $sportName'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: apiHandler.fetchCourseBySport(sportId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); 
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red), 
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final course = snapshot.data![0];
            final content = course['description'] ?? 'No content available.';
            final sections = CourseHelper.parseSections(content);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: sections.map((section) {
                  final title = section['title'] ?? 'No title';
                  final content = section['content'] ?? 'No content available';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0), 
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 235, 236, 236).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        width: double.infinity,
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8), 
                      Text(
                        content,
                        style: const TextStyle(fontSize: 16), 
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),
            );
          } else {
            return const Center(child: Text('No course found.')); 
          }
        },
      ),
    );
  }
}
