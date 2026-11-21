import 'package:get/get.dart';
import '../services/pasien_service.dart';
import '../controllers/pasien_controller.dart';

/// Binding untuk Dependency Injection GetX
class PasienBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PasienService>()) {
      Get.lazyPut<PasienService>(() => PasienService());
    }
    Get.lazyPut<PasienController>(
      () => PasienController(service: Get.find<PasienService>()),
    );
  }
}
