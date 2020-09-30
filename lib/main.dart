import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<Home> with TickerProviderStateMixin {
  AnimationController animationController;
  Animation<Offset> offset;
  Tween<Icon> animIcon;

  RxDouble top = RxDouble();
  final initialCrossFade = true.obs;

  //Vertical drag details
  DragStartDetails startVerticalDragDetails;
  DragUpdateDetails updateVerticalDragDetails;
  double lastValue = 0.0;
  double minValue = 0.0;
  double maxValue = 0.0;

  ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    top.value = 0;
    animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    offset = Tween<Offset>(begin: Offset(0.0, -300.0), end: Offset(0.0, -100.0))
        .animate(CurvedAnimation(
            parent: animationController, curve: Curves.elasticIn));

    animationController
        .forward()
        .whenComplete(() => animationController.reverse());


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Stack(
          children: [


           Obx(()=> Positioned(
             top: top.value + 100,
             child: Container(
               width: Get.width,
               height: Get.height - (top.value + 200),
               child: ListView.builder(
                 controller: scrollController,
                 itemCount: 30,
                 itemBuilder: (context, index) {
                   return ListTile(title: Text("Index : $index"));
                 },
               ),
             ),
           ),),

            _headerAnimation(),
          ],
        ),
      ),
    );
  }

  _headerAnimation() {
    return Obx(
      () => Positioned(
        top: top.value,
        child: AnimatedBuilder(
          builder: (BuildContext context, Widget child) {
            return Transform.translate(
                offset: offset.value,
                child: GestureDetector(

                  onVerticalDragStart: (dragDetails) {
                    startVerticalDragDetails = dragDetails;
                  },
                  onVerticalDragUpdate: (dragDetails) {
                    updateVerticalDragDetails = dragDetails;

                    double dx = updateVerticalDragDetails.globalPosition.dx -
                        startVerticalDragDetails.globalPosition.dx;
                    double dy = updateVerticalDragDetails.globalPosition.dy -
                        startVerticalDragDetails.globalPosition.dy;
                    if (dy == 0) dy = lastValue;

                    if (dy > 300) {
                      lastValue = 300;
                      debugPrint("primeiro if ${dy.floorToDouble()}");
                    } else if (dy < 0) {
                      debugPrint("segundo if ${dy.floorToDouble()}");
                      lastValue = 0;
                    } else {
                      debugPrint("else ${dy.floorToDouble()}");
                      lastValue = dy;
                    }
                    debugPrint("lastvalue ${lastValue.floorToDouble()}");
                    // print(lastValue.floorToDouble().toString());
                    top.value = lastValue;
                  },
                  onVerticalDragEnd: (endDetails) {
                    double dx = updateVerticalDragDetails.globalPosition.dx -
                        startVerticalDragDetails.globalPosition.dx;
                    double dy = updateVerticalDragDetails.globalPosition.dy -
                        startVerticalDragDetails.globalPosition.dy;
                    double velocity = endDetails.primaryVelocity;

                    //Convert values to be positive
                    top.value = lastValue;
                  },
                  child: Column(
                    children: [
                      Container(
                        width: Get.width,
                        height: 300,
                        color: Colors.red,
                      ),
                      Container(
                        color: Colors.blue,
                        width: Get.width,
                        height: 100,
                        child: Center(
                          child: Obx(() => AnimatedCrossFade(
                                crossFadeState: initialCrossFade.value
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                firstChild: Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 50,
                                ),
                                secondChild: Icon(
                                  Icons.keyboard_arrow_up,
                                  size: 50,
                                ),
                                duration: Duration(milliseconds: 500),
                              )),
                        ),
                      )
                    ],
                  ),
                ));
          },
          animation: animationController,
        ),
      ),
    );
  }
}
