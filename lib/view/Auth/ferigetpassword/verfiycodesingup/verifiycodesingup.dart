import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:service_electronic/core/class/statusRequest.dart';
import 'package:service_electronic/view/Auth/ferigetpassword/verfiycodesingup/verfiycodesingupController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class Verificodesingup extends StatelessWidget {
  Verificodesingup({Key? key}) : super(key: key);

  List<TextEditingController?> controllers = [];
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
        body: GetBuilder<VerficodesingupController>(
      init: VerficodesingupController(),
      builder: ((controller) => controller.statusRequest ==
              StatusRequest.loading
          ? Center(
              child: Lottie.asset("assets/lottie/loading1.json",
                  height: 80, width: 90),
            )
          : Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: ListView(children: [
                Column(
                  children: [
                    SizedBox(
                      height: h * 0.1,
                    ),
                    Stack(
                      alignment: Alignment.bottomLeft,
                      children: const [
                        Icon(
                          Icons.email_outlined,
                          color: Colors.red,
                          size: 80,
                        ),
                        Icon(
                          Icons.verified_user,
                          size: 50,
                          color: Colors.green,
                        ),
                      ],
                    ),
                    Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "57".tr,
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        )),
                    Container(
                      margin: const EdgeInsets.only(
                        bottom: 30,
                        left: 20,
                        right: 20,
                      ),
                      child: Text(
                        "58".tr,
                        style: const TextStyle(fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    OtpTextField(
                      keyboardType: TextInputType.number,
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      numberOfFields: 6,
                      borderColor: Colors.black,

                      //set to true to show as box or false to show as dash
                      showFieldAsBox: true,
                      //runs when a code is typed in
                      handleControllers: (controllers) =>
                          this.controllers = controllers,
                      //runs when every textfield is filled
                      onSubmit: (String verfycodesingup) {
                        controller.verifaycodesingup(verfycodesingup);
                      }, // end onSubmit
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Color.fromARGB(255, 233, 233, 233))),
                      onPressed: () async {
                        ClipboardData? cdata =
                            await Clipboard.getData(Clipboard.kTextPlain);
                        if (cdata != null &&
                            cdata.text != null &&
                            cdata.text!.length == 6 &&
                            int.tryParse(cdata.text!) != null) {
                          for (int i = 0; i < cdata.text!.length; i++) {
                            controllers[i]?.text =
                                cdata.text!.substring(i, i + 1);
                          }
                          // await Future.delayed(Duration(milliseconds: 500));
                          controller.verifaycodesingup(cdata.text!);
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '164'.tr,
                            style: const TextStyle(color: Colors.black),
                          ),
                          const Gap(5),
                          const Icon(Icons.link, color: Colors.black)
                        ],
                      ),
                    ),
                    InkWell(
                        onTap: controller.resendEmail,
                        child: Text(
                          "163".tr,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ))
                  ],
                ),
              ]),
            )),
    ));
  }
}
