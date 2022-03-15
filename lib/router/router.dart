// Enclave Route

import 'package:enclave/pages/browse/browse_page.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../../pages/about/about_page.dart';
import '../../pages/admin/admin_page.dart';
import '../../pages/board/board_page.dart';
import '../../pages/contact/contact_page.dart';
import '../../pages/distinct/distinct_page.dart';
import '../../pages/login/login_page.dart';
import '../../pages/member/member_page.dart';
import '../../pages/regulation/regulation_page.dart';
import '../../pages/setting/setting_page.dart';
import '../../pages/splash/splash_page.dart';
import '../../pages/system/system_page.dart';
import '../../pages/url/url_page.dart';
import '../pages/bulletin/bulletin_page.dart';
import '../pages/test/test_page.dart';

const String testRoute = "/test"; // shows initial login screen

const String splashRoute = "/splash"; // shows initial login screen
const String loginRoute = "/login"; // shows initial login screen
const String memberRoute = "/member"; // selected member info
const String browseRoute = "/browse"; // browse members info
const String distinctRoute = "/distinct"; // all member categorized by criteria

const String boardRoute = "/board"; // shows pdf file of directors board
const String regulationRoute = "/regulation"; // shows pdf file of enclave rule
const String contactRoute = "/contact"; // feedback or contact to board

const String aboutRoute = "/about"; // show app info
const String settingRoute = "/setting"; // setting app configuration
const String urlRoute = "/url"; // setting app configuration
const String bulletinRoute = "/bulletin"; // bulletin board app configuration

const String adminRoute = "/admin"; // show enclave administrator
const String systemRoute = "/system"; // show app system

///
/// Main Pages
///
List<GetPage<dynamic>> appPages() {
  return [
    GetPage(
      name: testRoute,
      page: () => TestPage(),
    ),
    GetPage(
      name: splashRoute,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: loginRoute,
      page: () => LoginPage(),
    ),
    GetPage(
      name: memberRoute,
      page: () => const MemberPage(),
    ),
    GetPage(
      name: browseRoute,
      page: () => BrowsePage(),
    ),
    GetPage(
      name: distinctRoute,
      page: () => DistinctPage(),
    ),
    GetPage(
      name: boardRoute,
      page: () => BoardPage(),
    ),
    GetPage(
      name: regulationRoute,
      page: () => RegulationPage(),
    ),
    GetPage(
      name: contactRoute,
      page: () => ContactPage(),
    ),
    GetPage(
      name: aboutRoute,
      page: () => AboutPage(),
    ),
    GetPage(
      name: settingRoute,
      page: () => SettingPage(),
    ),
    GetPage(
      name: urlRoute,
      page: () => UrlPage(),
    ),

    GetPage(
      name: bulletinRoute,
      page: () => BulletinPage(),
    ),

    // for EnclaveAdmin
    GetPage(
      name: adminRoute,
      page: () => AdminPage(),
    ),

    // for EnclaveSystem
    GetPage(
      name: systemRoute,
      page: () => SystemPage(),
    ),
  ];
}
