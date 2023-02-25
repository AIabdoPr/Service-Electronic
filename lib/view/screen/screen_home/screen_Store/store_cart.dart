import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../../Data/model/purchase.model.dart';
import '../../../../link_api.dart';
import '../../../../routes.dart';

class Notification extends StatelessWidget {
  const Notification({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 59, 214, 131),
        title: Center(
          child: Text(
            "123".tr,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: FutureBuilder(
        future: PurchaseModel.userLoadAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return StreamBuilder<List<PurchaseModel>>(
                stream: PurchaseModel.userStream(),
                builder: (context, snapshot) {
                  List<PurchaseModel> purchases =
                      snapshot.data?.reversed.toList() ?? [];
                  return ListView.builder(
                    itemCount: purchases.length,
                    itemBuilder: (context, index) {
                      PurchaseModel purchase = purchases[index];
                      return InkWell(
                        onTap: !['client_refuse', 'client_accept']
                                .contains(purchase.status)
                            ? () async {
                                await Get.toNamed(AppRoute.purchaseDetails,
                                    arguments: {
                                      'purchase': purchase,
                                      'target': 'user',
                                    });
                                PurchaseModel.sellerLoadAll();
                              }
                            : null,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 13, vertical: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 0.5, color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 1,
                                  spreadRadius: 1,
                                  offset: Offset(0.8, 0.5),
                                  color: Color.fromARGB(45, 0, 0, 0),
                                )
                              ]),
                          child: Row(
                            children: [
                              Container(
                                width: w * 0.2,
                                height: w * 0.2,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      purchase.product.sellerImageUrl,
                                      headers: Applink.imageHeaders,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const Gap(10),
                              // Flexible(
                              //   child: FittedBox(
                              //     child: Text(
                              //         '${"19.5".tr} : ${purchase.fullname}\n${"15".tr} : ${purchase.phone}\n${"31".tr} : ${purchase.product.name}\n${"33".tr} : ${purchase.totalPrice} DZD \n ${"142".tr} : ${purchase.count} unit'),
                              //   ),
                              // ),

                              Flexible(
                                child: FittedBox(
                                  child: Flex(
                                    direction: Axis.vertical,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "${"19.5".tr} : ${purchase.fullname}"),
                                      Text("${"15".tr} : ${purchase.phone}"),
                                      Text(
                                          "${"31".tr} : ${purchase.product.name}"),
                                      Text(
                                          "${"33".tr} : ${purchase.totalPrice} DZD \n ${"142".tr} : ${purchase.count} unit"),
                                    ],
                                  ),
                                ),
                              ),
                              // const Spacer(),
                              // Image.network(
                              //   purchase.product.imagesUrils[0],
                              //   height: h * 0.15,
                              // ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                });
          }
        },
      ),
    );
  }
}
