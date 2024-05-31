import 'dart:async';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sph_plan/client/client_submodules/substitutions.dart';
import 'package:sph_plan/shared/apps.dart';
import 'package:sph_plan/shared/exceptions/client_status_exceptions.dart';

import '../shared/types/fach.dart';
import 'client.dart';
import 'connection_checker.dart';

enum FetcherStatus {
  fetching,
  done,
  error;
}

class FetcherResponse<T> {
  late final FetcherStatus status;
  late final T? content;
  late final LanisException? error;

  FetcherResponse({required this.status, this.content, this.error});
}

abstract class Fetcher<T> {
  final BehaviorSubject<FetcherResponse<T>> _controller = BehaviorSubject();
  late Timer timer;
  late Duration? validCacheDuration;
  bool isEmpty = true;

  ValueStream<FetcherResponse<T>> get stream => _controller.stream;

  Fetcher(this.validCacheDuration) {
    if (validCacheDuration != null) {
      Timer.periodic(validCacheDuration!, (timer) async {
        if (await connectionChecker.connected) {
          await fetchData(forceRefresh: true);
        }
      });
    }
  }

  void _addResponse(final FetcherResponse<T> data) => _controller.sink.add(data);

  Future<void> fetchData({forceRefresh = false, secondTry = false}) async {
    if (!(await connectionChecker.connected)) {
      if (isEmpty) {
        _addResponse(FetcherResponse(
            status: FetcherStatus.error, error: NoConnectionException()));
      }

      return;
    }

    if (isEmpty || forceRefresh) {
      _addResponse(FetcherResponse(status: FetcherStatus.fetching));

      _get().then((data) async {
        _addResponse(
            FetcherResponse<T>(status: FetcherStatus.done, content: data));
        isEmpty = false;
        return;
      }).catchError((ex) async {
        if (!secondTry) {
          await client.login();
          await fetchData(forceRefresh: true, secondTry: true);
          return;
        }
        _addResponse(
            FetcherResponse<T>(status: FetcherStatus.error, error: ex));
      }, test: (e) => e is LanisException);
    }
  }

  Future<T> _get();
}

class SubstitutionsFetcher extends Fetcher<SubstitutionPlan> {
  SubstitutionsFetcher(super.validCacheDuration);

  @override
  Future<SubstitutionPlan> _get() async {
    return await client.substitutions.getAllSubstitutions(filtered: true);
  }
}

class MeinUnterrichtFetcher extends Fetcher<dynamic> {
  MeinUnterrichtFetcher(super.validCacheDuration);

  @override
  Future<dynamic> _get() {
    return client.meinUnterricht.getOverview();
  }
}

class VisibleConversationsFetcher extends Fetcher<dynamic> {
  VisibleConversationsFetcher(super.validCacheDuration);

  @override
  Future<dynamic> _get() {
    return client.conversations.getOverview(false);
  }
}

class InvisibleConversationsFetcher extends Fetcher<dynamic> {
  InvisibleConversationsFetcher(super.validCacheDuration);

  @override
  Future<dynamic> _get() {
    return client.conversations.getOverview(true);
  }
}

class CalendarFetcher extends Fetcher<dynamic> {
  CalendarFetcher(super.validCacheDuration);

  @override
  Future<dynamic> _get() {
    DateTime currentDate = DateTime.now();
    DateTime sixMonthsAgo = currentDate.subtract(const Duration(days: 180));
    DateTime oneYearLater = currentDate.add(const Duration(days: 365));

    final formatter = DateFormat('yyyy-MM-dd');

    return client.calendar.getCalendar(
        formatter.format(sixMonthsAgo), formatter.format(oneYearLater));
  }
}

class TimeTableFetcher extends Fetcher<List<List<StdPlanFach>>?> {
  TimeTableFetcher(super.validCacheDuration);

  @override
  Future<List<List<StdPlanFach>>?> _get() {
    return client.timetable.getPlan();
  }
}

class GlobalFetcher {
  late final SubstitutionsFetcher substitutionsFetcher;
  late final MeinUnterrichtFetcher meinUnterrichtFetcher;
  late final VisibleConversationsFetcher visibleConversationsFetcher;
  late final InvisibleConversationsFetcher invisibleConversationsFetcher;
  late final CalendarFetcher calendarFetcher;
  late final TimeTableFetcher timeTableFetcher;

  GlobalFetcher() {
    if (client.doesSupportFeature(SPHAppEnum.vertretungsplan)) {
      substitutionsFetcher = SubstitutionsFetcher(const Duration(minutes: 5));
    }
    if (client.doesSupportFeature(SPHAppEnum.meinUnterricht)) {
      meinUnterrichtFetcher =
          MeinUnterrichtFetcher(const Duration(minutes: 20));
    }
    if (client.doesSupportFeature(SPHAppEnum.nachrichten)) {
      visibleConversationsFetcher =
          VisibleConversationsFetcher(const Duration(minutes: 5));
      invisibleConversationsFetcher =
          InvisibleConversationsFetcher(const Duration(minutes: 5));
    }
    if (client.doesSupportFeature(SPHAppEnum.kalender)) {
      calendarFetcher = CalendarFetcher(null);
    }
    if (client.doesSupportFeature(SPHAppEnum.stundenplan)) {
      timeTableFetcher = TimeTableFetcher(null);
    }
  }
}
