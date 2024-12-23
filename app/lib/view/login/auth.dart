import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sph_plan/core/database/account_database/account_db.dart';
import 'package:sph_plan/core/sph/session.dart';
import 'package:sph_plan/models/client_status_exceptions.dart';
import 'package:sph_plan/view/login/school_selector.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/sph/sph.dart';
import '../../models/startup.dart';

class LoginForm extends StatefulWidget {
  final bool showBackButton;
  const LoginForm({required this.showBackButton, super.key});

  @override
  LoginFormState createState() {
    return LoginFormState();
  }
}

class LoginFormState extends State<LoginForm> {
  static const double padding = 10.0;

  final _formKey = GlobalKey<FormState>();

  TextEditingController schoolIDController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool dseAgree = false;
  String selectedSchoolName = "";


  void login(String username, String password, String schoolID) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.logInTitle),
              content: const Center(
                heightFactor: 1.2,
                child: CircularProgressIndicator(),
              ),
            ),
    );
    try {
      /*if (await accountDatabase.doesAccountExist(int.parse(schoolID), username)) {
        throw AccountAlreadyExistsException();
      }*/

      await SessionHandler.getLoginURL(
        ClearTextAccount(
          localId: -1,
          schoolID: int.parse(schoolID),
          username: username,
          password: password,
          schoolName: "",
        ),
      );

      int newID = await accountDatabase.addAccountToDatabase(
        schoolID: int.parse(schoolID),
        username: username,
        password: password,
        schoolName: selectedSchoolName,
      );
      await sph?.session.deAuthenticate();
      await accountDatabase.setNextLogin(newID);
      reset(context);
    } on LanisException catch (ex) {
      setState(() {
        Navigator.pop(context); //pop dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.error),
            content: Text(ex.cause),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("OK"))
            ],
          ),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    schoolIDController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.showBackButton) Padding(
          padding: EdgeInsets.only(right: 32, top: 32),
          child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(padding),
          child: Form(
            key: _formKey,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: padding,
                    ),
                    Center(
                      child: Column(
                        children: [
                          const Icon(Icons.person, size: 70),
                          Text(
                            AppLocalizations.of(context)!.logIn,
                            style: const TextStyle(fontSize: 35),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: padding * 5,
                    ),
                    SchoolSelector(
                      controller: schoolIDController,
                      outContext: context,
                      onSchoolSelected: (name) {
                        selectedSchoolName = name;
                        setState(() {});
                      },
                    ),
                    const SizedBox(
                      height: padding,
                    ),
                    TextFormField(
                      controller: usernameController,
                      enabled: schoolIDController.text != "",
                      autocorrect: false,
                      decoration: InputDecoration(
                          labelText:
                          AppLocalizations.of(context)!.authUsernameHint),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.authValidationError;
                        }

                        return null;
                      },
                    ),
                    const SizedBox(
                      height: padding,
                    ),
                    TextFormField(
                      controller: passwordController,
                      enabled: schoolIDController.text.isNotEmpty,
                      autocorrect: false,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.authPasswordHint,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.authValidationError;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: padding,
                    ),
                    Visibility(
                      child: ExcludeSemantics(
                        child: CheckboxListTile(
                          enabled: schoolIDController.text.isNotEmpty,
                          value: dseAgree,
                          title: RichText(
                            text: TextSpan(
                              text: AppLocalizations.of(context)!.authIAccept,
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan>[
                                TextSpan(
                                  text: AppLocalizations.of(context)!
                                      .authTermsOfService,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => launchUrl(Uri.parse(
                                        "https://github.com/alessioC42/lanis-mobile/blob/main/SECURITY.md")),
                                ),
                                TextSpan(
                                  text: AppLocalizations.of(context)!
                                      .authOfLanisMobile,
                                ),
                              ],
                            ),
                          ),
                          onChanged: (val) {
                            setState(() {
                              dseAgree = val!;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: padding,
                    ),
                    ElevatedButton(
                      onPressed: dseAgree
                          ? () {
                        if (_formKey.currentState!.validate()) {
                          login(usernameController.text,
                              passwordController.text, schoolIDController.text);
                        }
                      }
                          : null,
                      child: Text(AppLocalizations.of(context)!.logIn),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: schoolIDController.text.isNotEmpty ? () => launchUrl(Uri.parse(
                                "https://start.schulportal.hessen.de/benutzerverwaltung.php?a=userPWreminder&i=${schoolIDController.text}")) : null,
                            child: Text(
                                AppLocalizations.of(context)!.authResetPassword))
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
