import 'package:sph_plan/applets/calendar/parser.dart';
import 'package:sph_plan/applets/conversations/parser.dart';
import 'package:sph_plan/applets/lessons/teacher/parser.dart';
import 'package:sph_plan/applets/timetable/student/parser.dart';

import '../../applets/data_storage/parser.dart';
import '../../applets/lessons/student/parser.dart';
import '../../applets/substitutions/parser.dart';

class Parsers {
  SubstitutionsParser? _substitutionsParser;
  CalendarParser? _calendarParser;
  LessonsStudentParser? _lessonsStudentParser;
  LessonsTeacherParser? _lessonsTeacherParser;
  DataStorageParser? _dataStorageParser;
  TimetableStudentParser? _timetableStudentParser;
  ConversationsParser? _conversationsParser;

  SubstitutionsParser get substitutionsParser {
    _substitutionsParser ??= SubstitutionsParser();
    return _substitutionsParser!;
  }

  CalendarParser get calendarParser {
    _calendarParser ??= CalendarParser();
    return _calendarParser!;
  }

  LessonsStudentParser get lessonsStudentParser {
    _lessonsStudentParser ??= LessonsStudentParser();
    return _lessonsStudentParser!;
  }

  LessonsTeacherParser get lessonsTeacherParser {
    _lessonsTeacherParser ??= LessonsTeacherParser();
    return _lessonsTeacherParser!;
  }

  DataStorageParser get dataStorageParser {
    _dataStorageParser ??= DataStorageParser();
    return _dataStorageParser!;
  }

  TimetableStudentParser get timetableStudentParser {
    _timetableStudentParser ??= TimetableStudentParser();
    return _timetableStudentParser!;
  }

  ConversationsParser get conversationsParser {
    _conversationsParser ??= ConversationsParser();
    return _conversationsParser!;
  }
}