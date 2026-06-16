import 'quiz_model.dart';

class StoryModel {
  final String id;
  final String title;
  final List<String> sentences;
  final QuizModel? quiz;

  const StoryModel({
    required this.id,
    required this.title,
    required this.sentences,
    this.quiz,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      sentences: (json['sentences'] as List).map((s) => s as String).toList(),
      quiz: json['quiz'] != null
          ? QuizModel.fromJson(json['quiz'] as Map<String, dynamic>)
          : null,
    );
  }
}
