// Copyright (C) 2019 - present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parent/l10n/app_localizations.dart';
import 'package:flutter_parent/network/utils/api_prefs.dart';
import 'package:flutter_parent/screens/splash/splash_screen.dart';
import 'package:flutter_parent/screens/web_login/web_login_screen.dart';
import 'package:flutter_parent/utils/common_widgets/avatar.dart';
import 'package:flutter_parent/utils/common_widgets/user_name.dart';
import 'package:flutter_parent/utils/design/parent_theme.dart';
import 'package:flutter_parent/utils/quick_nav.dart';
import 'package:flutter_parent/utils/service_locator.dart';
import 'package:flutter_parent/utils/snickers.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

import 'domain_search/domain_search_screen.dart';

class LoginLandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultParentTheme(
      builder: (context) => Scaffold(
        endDrawer: kReleaseMode
            ? null // Don't show snickers in release mode
            : Drawer(
                child: SafeArea(
                  child: Center(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: SNICKERS.length,
                      itemBuilder: (context, index) {
                        var snicker = SNICKERS[index];
                        return ListTile(
                          title: Text(snicker.title),
                          subtitle: Text(snicker.subtitle),
                          onTap: () {
                            // TODO: needs test
                            locator<QuickNav>().push(
                              context,
                              WebLoginScreen(snicker.domain, user: snicker.username, pass: snicker.password),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
        body: Column(
          children: <Widget>[
            Expanded(child: _body(context)),
            _previousLogins(context),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/svg/canvas-parent-login-logo.svg',
            semanticsLabel: L10n(context).canvasLogoLabel,
          ),
          SizedBox(height: 64),
          RaisedButton(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                L10n(context).findSchool,
                style: TextStyle(fontSize: 16),
              ),
            ),
            color: Theme.of(context).accentColor,
            textColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
            onPressed: () {
              onFindSchoolPressed(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _previousLogins(BuildContext context) {
    final itemHeight = 72.0;
    return StatefulBuilder(
      builder: (context, setState) {
        var logins = ApiPrefs.getLogins();
        if (logins.isEmpty) return Container();
        return Column(
          key: Key('previous-logins'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(L10n(context).previousLogins, style: Theme.of(context).textTheme.caption),
            ),
            SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1),
            ),
            AnimatedContainer(
              curve: Curves.easeInOutBack,
              duration: Duration(milliseconds: 400),
              height: min(itemHeight * 2, itemHeight * logins.length),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 0),
                itemCount: logins.length,
                itemBuilder: (context, index) {
                  var login = logins[index];
                  return ListTile(
                    onTap: () {
                      ApiPrefs.switchLogins(login);
                      locator<QuickNav>().pushAndRemoveAll(context, SplashScreen());
                    },
                    leading: Avatar.fromUser(login.user),
                    title: UserName.fromUser(login.user),
                    subtitle: Text(login.domain),
                    trailing: IconButton(
                      tooltip: L10n(context).delete,
                      onPressed: () async {
                        await ApiPrefs.removeLogin(login);
                        setState(() {});
                      },
                      icon: Icon(Icons.clear),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  onFindSchoolPressed(BuildContext context) {
    locator<QuickNav>().push(context, DomainSearchScreen());
  }
}
