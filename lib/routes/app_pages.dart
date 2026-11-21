import 'package:get/get.dart';
import '../bindings/pasien_binding.dart';
import '../views/home_view.dart';
import '../views/form_pasien_view.dart';
import '../views/detail_pasien_view.dart';
import 'app_routes.dart';

/// Konfigurasi routing GetX AppPages
class AppPages {
  static const initial = AppRoutes.home;

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: PasienBinding(),
    ),
    GetPage(
      name: AppRoutes.form,
      page: () => const FormPasienView(),
      binding: PasienBinding(),
    ),
    GetPage(
      name: AppRoutes.detail,
      page: () => const DetailPasienView(),
      binding: PasienBinding(),
    ),
  ];
}
