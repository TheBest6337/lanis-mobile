import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sph_plan/applets/study_groups/definitions.dart';
import 'package:sph_plan/core/sph/sph.dart';
import 'package:sph_plan/widgets/combined_applet_builder.dart';

class StudentStudyGroupsView extends StatefulWidget {
  const StudentStudyGroupsView({super.key});

  @override
  State<StudentStudyGroupsView> createState() => _StudentStudyGroupsViewState();
}

class _StudentStudyGroupsViewState extends State<StudentStudyGroupsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CombinedAppletBuilder(
          parser: sph!.parser.studyGroupsStudentParser,
          phpUrl: studyGroupsDefinition.appletPhpUrl,
          settingsDefaults: studyGroupsDefinition.settingsDefaults,
          accountType: sph!.session.accountType,
          builder:
              (context, data, accountType, settings, updateSetting, refresh) {
            //
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                if (data[index].exams.isEmpty) return Container();
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(data[index].courseName),
                          Text(data[index].teacher),
                          Text(DateFormat('dd.MM.yy')
                              .format(data[index].exams[0].date)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(data[index].exams[0].type),
                          data[index].exams[0].duration.isEmpty
                              ? Text(data[index].exams[0].time)
                              : Text(
                                  '${data[index].exams[0].time} (${data[index].exams[0].duration})'),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }),
    );
  }
}
