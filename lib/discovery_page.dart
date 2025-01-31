import 'package:flutter/material.dart';
import 'package:habit_hacker_testing_project/components/color.dart';
import 'package:habit_hacker_testing_project/components/custom_text.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key});

  @override
  State<DiscoveryPage> createState() => _MyDiscoveryPageState();
}

class _MyDiscoveryPageState extends State<DiscoveryPage> {
  double _sliderValue = 4;
  List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double progressBarWidth = screenWidth * 0.5;
    double imageWidth = screenWidth * 0.7;
    double imageHeight = screenWidth * 0.7;
    return Scaffold(
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    onPressed: null,
                    child: CustomText(
                      text: "",
                      color: MyColor().colorGrey1,
                    )),
                CustomText(
                  text: 'Discovery',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: MyColor().colorGrey,
                ),
                TextButton(
                    onPressed: null,
                    child: CustomText(
                      text: "Next",
                      color: MyColor().colorGrey1,
                      fontSize: 22,
                    ))
              ],
            ),
            const SizedBox(height: 16),

            // Progress Bar
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: progressBarWidth,
                    child: LinearProgressIndicator(
                      value: 0.07,
                      backgroundColor: Colors.grey[350], // Customize
                      minHeight: 20,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(MyColor().colorGrey!),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomText(
                        text: '7%',
                        color: MyColor().colorGreen,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(width: 20),
                      CustomText(
                        text: 'Discovered',
                        color: MyColor().colorGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            CustomText(
              text: 'How you perceive yourself overall?',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: MyColor().colorGrey1,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Column(
                children: [
                  Slider(
                    value: _sliderValue,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    thumbColor: MyColor().colorGrey,
                    activeColor: MyColor().colorGrey,
                    label: _sliderValue.round().toString(),
                    onChanged: (double newValue) {
                      setState(() {
                        _sliderValue = newValue;
                      });
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(8, 0, 4, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: numbers.map((number) {
                        return CustomText(
                          text: number.toString(),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
            ),
            // Slider
            const SizedBox(height: 32),
            CustomText(
              text: "1 of 14",
              color: MyColor().colorOrange,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            Image.asset('assets/discovery1.png', width: imageWidth, height: imageHeight,)
          ],
        ),
      ),
    );
  }
}
