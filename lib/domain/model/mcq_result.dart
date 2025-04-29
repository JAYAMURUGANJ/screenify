class MCQResult {
  int? totalQuestions;
  int? correctCount;
  int? wrongCount;
  int? score;
  String? scorePercentage;
  List<Questions>? questions;

  MCQResult({
    this.totalQuestions,
    this.correctCount,
    this.wrongCount,
    this.score,
    this.scorePercentage,
    this.questions,
  });

  MCQResult.fromJson(Map<String, dynamic> json) {
    totalQuestions = json['totalQuestions'];
    correctCount = json['correctCount'];
    wrongCount = json['wrongCount'];
    score = json['score'];
    scorePercentage = json['scorePercentage'];
    if (json['questions'] != null) {
      questions = <Questions>[];
      json['questions'].forEach((v) {
        questions!.add(Questions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalQuestions'] = totalQuestions;
    data['correctCount'] = correctCount;
    data['wrongCount'] = wrongCount;
    data['score'] = score;
    data['scorePercentage'] = scorePercentage;
    if (questions != null) {
      data['questions'] = questions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Questions {
  String? question;
  int? selectedAnswerIndex;
  int? correctAnswerIndex;
  bool? isCorrect;

  Questions({
    this.question,
    this.selectedAnswerIndex,
    this.correctAnswerIndex,
    this.isCorrect,
  });

  Questions.fromJson(Map<String, dynamic> json) {
    question = json['question'];
    selectedAnswerIndex = json['selectedAnswerIndex'];
    correctAnswerIndex = json['correctAnswerIndex'];
    isCorrect = json['isCorrect'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['question'] = question;
    data['selectedAnswerIndex'] = selectedAnswerIndex;
    data['correctAnswerIndex'] = correctAnswerIndex;
    data['isCorrect'] = isCorrect;
    return data;
  }
}

//sample json
// {
//     "totalQuestions": 20,
//     "correctCount": 7,
//     "wrongCount": 13,
//     "score": 7,
//     "scorePercentage": "35.0",
//     "questions": [
//         {
//             "question": "What is the capital of France?",
//             "selectedAnswerIndex": 0,
//             "correctAnswerIndex": 2,
//             "isCorrect": false
//         },
//         {
//             "question": "Which planet is known as the Red Planet?",
//             "selectedAnswerIndex": 3,
//             "correctAnswerIndex": 1,
//             "isCorrect": false
//         },
//         {
//             "question": "Who wrote 'Romeo and Juliet'?",
//             "selectedAnswerIndex": 2,
//             "correctAnswerIndex": 1,
//             "isCorrect": false
//         },
//         {
//             "question": "What is the largest ocean on Earth?",
//             "selectedAnswerIndex": 1,
//             "correctAnswerIndex": 3,
//             "isCorrect": false
//         },
//         {
//             "question": "What is the chemical symbol for gold?",
//             "selectedAnswerIndex": 0,
//             "correctAnswerIndex": 2,
//             "isCorrect": false
//         },
//         {
//             "question": "Which country is known as the Land of the Rising Sun?",
//             "selectedAnswerIndex": 2,
//             "correctAnswerIndex": 2,
//             "isCorrect": true
//         },
//         {
//             "question": "What is the main component of the Earth's atmosphere?",
//             "selectedAnswerIndex": 2,
//             "correctAnswerIndex": 2,
//             "isCorrect": true
//         },
//         {
//             "question": "Which of these is not a primary color?",
//             "selectedAnswerIndex": 3,
//             "correctAnswerIndex": 3,
//             "isCorrect": true
//         },
//         {
//             "question": "Who painted the Mona Lisa?",
//             "selectedAnswerIndex": 2,
//             "correctAnswerIndex": 2,
//             "isCorrect": true
//         },
//         {
//             "question": "What is the smallest prime number?",
//             "selectedAnswerIndex": 2,
//             "correctAnswerIndex": 2,
//             "isCorrect": true
//         },
//         {
//             "question": "Which planet has the most moons?",
//             "selectedAnswerIndex": 2,
//             "correctAnswerIndex": 1,
//             "isCorrect": false
//         },
//         {
//             "question": "What is the hardest natural substance on Earth?",
//             "selectedAnswerIndex": 3,
//             "correctAnswerIndex": 2,
//             "isCorrect": false
//         },
//         {
//             "question": "Which animal is known as the 'King of the Jungle'?",
//             "selectedAnswerIndex": 0,
//             "correctAnswerIndex": 1,
//             "isCorrect": false
//         },
//         {
//             "question": "What is the largest internal organ in the human body?",
//             "selectedAnswerIndex": 1,
//             "correctAnswerIndex": 1,
//             "isCorrect": true
//         },
//         {
//             "question": "In which year did World War II end?",
//             "selectedAnswerIndex": 1,
//             "correctAnswerIndex": 2,
//             "isCorrect": false
//         },
//         {
//             "question": "Which is the longest river in the world?",
//             "selectedAnswerIndex": 0,
//             "correctAnswerIndex": 1,
//             "isCorrect": false
//         },
//         {
//             "question": "What is the capital of Japan?",
//             "selectedAnswerIndex": 3,
//             "correctAnswerIndex": 2,
//             "isCorrect": false
//         },
//         {
//             "question": "Which continent is the largest by land area?",
//             "selectedAnswerIndex": 2,
//             "correctAnswerIndex": 3,
//             "isCorrect": false
//         },
//         {
//             "question": "Who discovered penicillin?",
//             "selectedAnswerIndex": 1,
//             "correctAnswerIndex": 0,
//             "isCorrect": false
//         },
//         {
//             "question": "What is the currency of Brazil?",
//             "selectedAnswerIndex": 3,
//             "correctAnswerIndex": 3,
//             "isCorrect": true
//         }
//     ]
// }
