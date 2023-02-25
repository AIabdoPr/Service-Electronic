import 'package:service_electronic/Data/model/offer.model.dart';
import 'package:service_electronic/Data/model/offer_request.dart';
import 'package:service_electronic/core/class/statusRequest.dart';
import 'package:service_electronic/routes.dart';

import 'package:get/get.dart';

class ServiceController extends GetxController {
  int contry = 0;
  StatusRequest statusRequest = StatusRequest.loading;

  RxList<OfferModel> offers = <OfferModel>[].obs;
  RxList<OfferRequestModel> offersRequests = <OfferRequestModel>[].obs;
  RxMap<int, String> selectedSubOffer = <int, String>{}.obs;
  RxMap<int, String> validates = <int, String>{}.obs;

  @override
  void onInit() {
    getOffers();
    super.onInit();
  }

  Future getOffers() async {
    statusRequest = StatusRequest.loading;
    update();
    offers.value = await OfferModel.loadAll();
    await getOffersRequests();
    statusRequest = StatusRequest.success;
    update();
  }

  Future getOffersRequests() async {
    offersRequests.value = await OfferRequestModel.loadAll();
    update();
  }

  Future submitOffer(OfferModel offer) async {
    if (selectedSubOffer.containsKey(offer.id) ||
        selectedSubOffer[offer.id] == '-1') {
      validates[offer.id] = 'Please select offer';
      update();
    }
  }

  var selctedmodel;
  void changeservice(String value) {
    selctedmodel = value;
    update();
  }

  Notificationservice() {
    Get.toNamed(AppRoute.notification);
  }
}
