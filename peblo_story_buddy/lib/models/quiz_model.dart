class QuizOptionModel {
  final String text;
  final bool isCorrect;

  const QuizOptionModel({
    required this.text,
    required this.isCorrect,
  });

  factory QuizOptionModel.fromJson(Map<String, dynamic> json) {
    return QuizOptionModel(
      text: json['text'] as String,
      isCorrect: json['isCorrect'] as bool,
    );
  }
}

class QuizQuestionModel {
  final String question;
  final List<QuizOptionModel> options;

  const QuizQuestionModel({
    required this.question,
    required this.options,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      question: json['question'] as String,
      options: (json['options'] as List)
          .map((o) => QuizOptionModel.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuizModel {
  final List<QuizQuestionModel> questions;

  const QuizModel({required this.questions});

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      questions: (json['questions'] as List)
          .map((q) => QuizQuestionModel.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}
