import 'package:flutter/material.dart';
import 'package:sph_plan/applets/calendar/definition.dart';
import 'package:sph_plan/applets/conversations/definition.dart';
import 'package:sph_plan/applets/data_storage/definition.dart';
import 'package:sph_plan/applets/lessons/definition.dart';
import 'package:sph_plan/applets/study_groups/definitions.dart';
import 'package:sph_plan/applets/substitutions/definition.dart';
import 'package:sph_plan/applets/timetable/definition.dart';
import 'package:sph_plan/models/account_types.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

import '../background_service.dart';
import '../core/sph/sph.dart';

typedef StringBuildContextCallback = String Function(BuildContext context);
typedef WidgetBuildBody = Widget Function(BuildContext context, AccountType accountType, Function? openDrawerCb);
typedef BackgroundTaskFunction = Future<void> Function(SPH sph, AccountType accountType, BackgroundTaskToolkit toolkit);

enum AppletType {
  nested,
  navigation,
}

class AppletDefinition {
  final String appletPhpUrl;
  final Icon icon;
  final Icon selectedIcon;
  final AppletType appletType;
  final bool addDivider;
  final StringBuildContextCallback label;
  final List<AccountType> supportedAccountTypes;
  final bool allowOffline;
  final Duration refreshInterval;
  final Map<String, dynamic> settingsDefaults;
  WidgetBuildBody? bodyBuilder;
  BackgroundTaskFunction? notificationTask;

  bool get enableBottomNavigation => appletType == AppletType.nested;

  AppletDefinition({
    required this.appletPhpUrl,
    required this.icon,
    required this.selectedIcon,
    required this.appletType,
    required this.addDivider,
    required this.label,
    required this.supportedAccountTypes,
    required this.refreshInterval,
    required this.settingsDefaults,
    this.notificationTask,
    this.bodyBuilder,
    this.allowOffline = false,
  });

  Future<void> importTimetableSettings(
      Future<void> Function(String, dynamic) updateSettings) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> importedSettings = jsonDecode(jsonString);

      for (var key in importedSettings.keys) {
        await updateSettings(key, importedSettings[key]);
      }

      showSnackbar(context, 'Timetable settings imported successfully.');
    }
  }

  Future<void> exportTimetableSettings(Map<String, dynamic> settings) async {
    final jsonString = jsonEncode(settings);
    final fileName = 'timetable_settings.json';
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Timetable Settings',
      fileName: fileName,
    );

    if (result != null) {
      final file = File(result);
      await file.writeAsString(jsonString);
      showSnackbar(context, 'Timetable settings exported successfully.');
    }
  }

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}

class AppDefinitions {
  static List<AppletDefinition> applets = [
    substitutionDefinition,
    calendarDefinition,
    timeTableDefinition,
    conversationsDefinition,
    lessonsDefinition,
    dataStorageDefinition,
    studyGroupsDefinition
  ];

  static bool isAppletSupported(AccountType accountType, String phpIdentifier) {
    return applets.any((element) =>
        element.supportedAccountTypes.contains(accountType) &&
        element.appletPhpUrl == phpIdentifier);
  }

  static getByPhpIdentifier(String phpIdentifier) {
    return applets
        .firstWhere((element) => element.appletPhpUrl == phpIdentifier);
  }

  static getIndexByPhpIdentifier(String phpIdentifier) {
    return applets
        .indexWhere((element) => element.appletPhpUrl == phpIdentifier);
  }
}
