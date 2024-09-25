typedef Lessons = List<Lesson>;

class Lesson {
  String courseID;
  String name;
  String? teacher;
  String? teacherKuerzel;
  Uri courseURL;
  Map<String, String>? attendances;
  CurrentEntry? currentEntry;

  Lesson({required this.courseID, required this.name, required this.teacher, this.teacherKuerzel, required this.courseURL, this.attendances, this.currentEntry});
}

class DetailedLesson {
  String courseID;
  String name;
  String teacher;
  String teacherKuerzel;
  List<CurrentEntry> history;
  List<LessonMark> marks;
  List<LessonExam> exams;
  Map<String, String> attendances;
  Uri? semester1URL;

  DetailedLesson({required this.courseID, required this.name, required this.teacher, required this.teacherKuerzel, required this.history, required this.marks, required this.exams, required this.attendances, this.semester1URL});
}

class LessonExam {
  String name;
  String? value;

  LessonExam({required this.name, this.value});
}

class LessonMark {
  String name;
  String date;
  String note;
  String? comment;

  LessonMark({required this.name, required this.date, required this.note, this.comment});
}

class CurrentEntry {
  String entryID;
  String? topicTitle;
  String? description;
  DateTime? topicDate;
  String? schoolHours;
  Homework? homework;
  List<LessonsFile> files;

  CurrentEntry({required this.entryID, required this.files, this.topicTitle, this.topicDate, this.homework, this.schoolHours, this.description});
}

class Homework {
  String description;
  bool homeWorkDone;

  Homework({required this.description, required this.homeWorkDone});
}

class LessonsFile {
  String? fileName;
  String? fileSize;
  Uri? fileURL;
  
  LessonsFile({this.fileName, this.fileSize, this.fileURL});
}

class LessonUpload {
  String name;
  String status; //todo replace with enum
  Uri url;
  String? uploaded;
  String? date; //todo replace with DateTime

  LessonUpload({required this.name, required this.status, required this.url, this.uploaded, this.date});
}