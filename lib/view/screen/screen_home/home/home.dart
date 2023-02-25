import 'package:gap/gap.dart';
import 'package:intl/intl.dart' as intl;
import 'package:service_electronic/Data/model/notification.model.dart';
import 'package:service_electronic/controller/controller_home.dart';
import 'package:service_electronic/core/function/dealogAlartback.dart';
import 'package:service_electronic/link_api.dart';
import 'package:service_electronic/view/screen/screen_home/home/drawor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:service_electronic/view/widget/network_image.view.dart';
import '../../../../core/class/statusRequest.dart';
import '../../../../core/constant/circleraviter.dart';
import '../../../../core/constant/icon_Bottun.dart';
import '../../../../core/services/notifiction.service.dart';
import '../../../../routes.dart';
import '../../../widget/bottun_screen.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return controller.statusRequest == StatusRequest.loading
            ? Center(
                child: Lottie.asset("assets/lottie/loading1.json",
                    height: 80, width: 90),
              )
            : GestureDetector(
                onTap: () {
                  controller.showNotifications.value = false;
                  controller.update();
                },
                child: Scaffold(
                  appBar: AppBar(
                      backgroundColor: const Color.fromARGB(255, 8, 8, 8),
                      title: Center(
                        child: Text(
                          "13".tr,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      actions: [
                        MyIconBottun(
                          count: Get.find<NotificationService>()
                              .newsTransfers
                              .value,
                          radius: 8,
                          onTap: () async {
                            await Get.toNamed(AppRoute.homeCart);
                            Get.find<NotificationService>()
                                .newsTransfers
                                .value = 0;
                          },
                          icon: Icons.notifications_on,
                        ),
                        mycircleraviter(
                          image: "assets/images/logo3.png",
                          minRadius: 5,
                          maxRadius: 23,
                          height: h * 0.50,
                          width: w * 0.50,
                          backgroundColor: Colors.white,
                        ),
                      ]),
                  drawer: MyDrawer(onTap: controller.singOut),
                  floatingActionButton: Stack(
                    children: [
                      FloatingActionButton(
                        key: controller.floatingButtonKey,
                        onPressed: controller.openNotifications,
                        elevation: 10,
                        child: const Icon(
                          Icons.message_outlined,
                          size: 35,
                        ),
                      ),
                      // if (controller.notifictionCount != 0)
                      if (Get.find<NotificationService>()
                              .newsAdminMessages
                              .value !=
                          0)
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 13,
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 12,
                            child: FittedBox(
                                child: Text(
                              Get.find<NotificationService>()
                                          .newsAdminMessages
                                          .value >
                                      9
                                  ? "9+"
                                  : "${Get.find<NotificationService>().newsAdminMessages.value}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            )),
                          ),
                        ),
                    ],
                  ),
                  body: Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: controller.refreshPage,
                        child: WillPopScope(
                          onWillPop: alirtExitApp,
                          child: LayoutBuilder(
                            builder: (context, constrains) {
                              if (constrains.maxWidth <= 940) {
                                return Obx(
                                  () => ListView(
                                    children: [
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: h * 0.08,
                                          ),
                                          if (controller
                                                      .user
                                                      .value!
                                                      .platformSettings
                                                      .servicesStatus[
                                                  'transfers'] ==
                                              'active')
                                            BottunScreen(
                                              height: h * 0.35,
                                              width: w * 0.65,
                                              assetName:
                                                  ("assets/images/chonge.png"),
                                              decoration: const BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage(""),
                                                ),
                                              ),
                                              text: "12".tr,
                                              onPressed: () {
                                                controller.echonge();
                                              },
                                              color: Colors.white,
                                            ),
                                          if (controller
                                                  .user
                                                  .value!
                                                  .platformSettings
                                                  .servicesStatus['offers'] ==
                                              'active')
                                            BottunScreen(
                                              height: h * 0.35,
                                              width: w * 0.65,
                                              assetName:
                                                  ("assets/images/Service.png"),
                                              decoration: const BoxDecoration(
                                                  image: DecorationImage(
                                                      image: AssetImage(""))),
                                              text: "9".tr,
                                              onPressed: () {
                                                controller.service();
                                              },
                                              color: Colors.white,
                                            ),
                                          // BottunScreen(
                                          //   height: h * 0.35,
                                          //   width: w * 0.65,
                                          //   assetName:
                                          //       ("assets/images/flixi2.png"),
                                          //   decoration: const BoxDecoration(
                                          //       image: DecorationImage(
                                          //           image: AssetImage(""))),
                                          //   text: "10".tr,
                                          //   onPressed: () {},
                                          //   color: Colors.white,
                                          // ),
                                          if (controller
                                                  .user
                                                  .value!
                                                  .platformSettings
                                                  .servicesStatus['store'] ==
                                              'active')
                                            BottunScreen(
                                              height: h * 0.35,
                                              width: w * 0.65,
                                              assetName:
                                                  ("assets/images/store.png"),
                                              decoration: const BoxDecoration(
                                                  image: DecorationImage(
                                                      image: AssetImage(""))),
                                              text: "11".tr,
                                              onPressed: controller.myStore,
                                              color: Colors.white,
                                            ),
                                          // BottunScreen(
                                          //   height: h * 0.35,
                                          //   width: w * 0.65,
                                          //   assetName:
                                          //       ("assets/images/programer.png"),
                                          //   decoration: const BoxDecoration(
                                          //       image: DecorationImage(
                                          //           image: AssetImage(""))),
                                          //   text: "104".tr,
                                          //   onPressed: () {},
                                          //   color: Colors.white,
                                          // ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return Obx(
                                  () => GridView(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            mainAxisSpacing: 10,
                                            crossAxisSpacing: 10),
                                    children: [
                                      SizedBox(
                                        height: h * 0.08,
                                      ),
                                      if (controller
                                              .user
                                              .value!
                                              .platformSettings
                                              .servicesStatus['transfers'] ==
                                          'active')
                                        BottunScreen(
                                          height: h * 0.35,
                                          width: w * 0.65,
                                          assetName:
                                              ("assets/images/chonge.png"),
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(""),
                                            ),
                                          ),
                                          text: "12".tr,
                                          onPressed: controller.echonge,
                                          color: Colors.white,
                                        ),
                                      if (controller
                                              .user
                                              .value!
                                              .platformSettings
                                              .servicesStatus['offers'] ==
                                          'active')
                                        BottunScreen(
                                          height: h * 0.35,
                                          width: w * 0.65,
                                          assetName:
                                              ("assets/images/Service.png"),
                                          decoration: const BoxDecoration(
                                              image: DecorationImage(
                                                  image: AssetImage(""))),
                                          text: "9".tr,
                                          onPressed: controller.service,
                                          color: Colors.white,
                                        ),
                                      // BottunScreen(
                                      //   height: h * 0.35,
                                      //   width: w * 0.65,
                                      //   assetName: ("assets/images/flixi2.png"),
                                      //   decoration: const BoxDecoration(
                                      //       image: DecorationImage(
                                      //           image: AssetImage(""))),
                                      //   text: "10".tr,
                                      //   onPressed: () {},
                                      //   color: Colors.white,
                                      // ),
                                      if (controller
                                              .user
                                              .value!
                                              .platformSettings
                                              .servicesStatus['store'] ==
                                          'active')
                                        BottunScreen(
                                          height: h * 0.35,
                                          width: w * 0.65,
                                          assetName:
                                              ("assets/images/store.png"),
                                          decoration: const BoxDecoration(
                                              image: DecorationImage(
                                                  image: AssetImage(""))),
                                          text: "11".tr,
                                          onPressed: controller.myStore,
                                          color: Colors.white,
                                        ),
                                      // BottunScreen(
                                      //   height: h * 0.35,
                                      //   width: w * 0.65,
                                      //   assetName:
                                      //       ("assets/images/programer.png"),
                                      //   decoration: const BoxDecoration(
                                      //       image: DecorationImage(
                                      //           image: AssetImage(""))),
                                      //   text: "104".tr,
                                      //   onPressed: () {},
                                      //   color: Colors.white,
                                      // ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      if (controller.showNotifications.value)
                        Positioned(
                          bottom: (controller
                                      .floatingButtonRenderBox?.size.height ??
                                  0) +
                              25,
                          left: w * 0.05,
                          width: w * 0.9,
                          height: h * 0.45,
                          child: WillPopScope(
                            onWillPop: () async {
                              controller.showNotifications.value = false;
                              controller.update();
                              return false;
                            },
                            child: Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    textDirection: TextDirection.ltr,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Spacer(),
                                      IconButton(
                                        onPressed: controller.loadNotifications,
                                        icon: const Icon(
                                          Icons.refresh,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          controller.showNotifications.value =
                                              false;

                                          controller.update();
                                        },
                                        icon: const Icon(
                                          Icons.cancel,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Flexible(
                                    child: controller.loadingNotifictions.isTrue
                                        ? const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.black,
                                            ),
                                          )
                                        : ListView.builder(
                                            itemCount:
                                                controller.notifications.length,
                                            itemBuilder: (context, index) {
                                              NotificationModel notification =
                                                  controller.notifications[
                                                      controller.notifications
                                                              .length -
                                                          1 -
                                                          index];

                                              return Card(
                                                color: const Color.fromARGB(
                                                    255, 235, 235, 235),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 10,
                                                      horizontal: 15),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      NetworkImageView(
                                                        url: notification
                                                            .imageUrl,
                                                        headers: Applink
                                                            .imageHeaders,
                                                        borderRadius: 20,
                                                        fit: BoxFit.fill,
                                                        width: w * 0.11,
                                                        height: w * 0.11,
                                                      ),
                                                      const Gap(10),
                                                      Flexible(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              notification
                                                                  .title,
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            Text(
                                                              notification
                                                                  .message,
                                                            ),
                                                            Text(
                                                              intl.DateFormat(
                                                                'yyyy-MM-dd HH:mm',
                                                              ).format(
                                                                notification
                                                                    .sendedAt,
                                                              ),
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          10),
                                                            ),
                                                            if (notification
                                                                    .attachmentImageUrl !=
                                                                null) ...[
                                                              const Gap(10),
                                                              NetworkImageView(
                                                                height:
                                                                    h * 0.25,
                                                                width: double
                                                                    .infinity,
                                                                url: notification
                                                                    .attachmentImageUrl!,
                                                                headers: Applink
                                                                    .imageHeaders,
                                                                fit:
                                                                    BoxFit.fill,
                                                                setItInDecoration:
                                                                    true,
                                                              )
                                                            ]
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
      },
    );
  }
}
