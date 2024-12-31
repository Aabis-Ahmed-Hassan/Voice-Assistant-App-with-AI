import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_assistant_with_ai/colors.dart';
import 'package:voice_assistant_with_ai/gemeni_services.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  SpeechToText _speechToText = SpeechToText();

  bool isLoading = false;
  String prompt = 'Hello World';
  String gemeniResponse = 'Good Morning! What can I do for you?';

  final _promptController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSTT();
  }

  Future<void> initSTT() async {
    await _speechToText.initialize();
    setState(() {});
  }

  Future<void> _startRecording() async {
    print('start recording is called');

    await _speechToText.listen(onResult: _speechResult);
  }

  Future<void> _speechResult(SpeechRecognitionResult voice) async {
    prompt = voice.recognizedWords;
    _promptController.text = voice.recognizedWords;
    setState(() {});
    print('hello');
  }

  Future<void> _stopRecording() async {
    print('stop recording is called');
    await _speechToText.stop();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _speechToText.stop();
  }

  Future<void> _hitApi(String prompt) async {
    setState(() {
      isLoading = true;
    });
    gemeniResponse = await GemeniServices().isImage(prompt);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Voice Assistant',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
              _hitApi(prompt);
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              // 'Voice Assistant',
              prompt.toString(),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w500,
              ),
            ),
            Stack(
              children: [
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    margin: EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Pallete.assistantCircleColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  height: 125,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/virtualAssistant.png'),
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(
                top: 20,
                bottom: 16,
                left: 10,
                right: 10,
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Pallete.borderColor,
                ),
                borderRadius: BorderRadius.circular(20).copyWith(
                  topLeft: Radius.zero,
                ),
              ),
              child: SizedBox(
                height: 200,
                child: isLoading
                    ? Text('Generating...')
                    : ListView(
                        children: [
                          Text(
                            gemeniResponse.toString(),
                            style: TextStyle(
                              fontFamily: 'Cera Pro',
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            // Align(
            //   alignment: Alignment.centerLeft,
            //   child: Text(
            //     'Here a few features',
            //     style: TextStyle(
            //       fontFamily: 'Cera Pro',
            //       fontSize: 23,
            //       fontWeight: FontWeight.w500,
            //     ),
            //   ),
            // ),
            // FeatureBox(
            //   title: 'ChatGPT',
            //   description: 'A smarter way to access ChatGPT.',
            //   color: Pallete.firstSuggestionBoxColor,
            // ),
            // FeatureBox(
            //   title: 'Dall-E',
            //   description: 'A smarter way to access Dall-E.',
            //   color: Pallete.secondSuggestionBoxColor,
            // ),
            // FeatureBox(
            //   title: 'Smart Voice Assistant',
            //   description: 'A smarter way to access Smart Voice Assistant.',
            //   color: Pallete.firstSuggestionBoxColor,
            // ),
            // ElevatedButton(
            //   onPressed: () async {
            //     await _hitApi(prompt);
            //   },
            //   child: Text('Gemeni'),
            // ),
            Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: TextField(
                  controller: _promptController,
                  onChanged: (e) {
                    prompt = e;
                    // to change icon
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    suffixIcon: InkWell(
                      onTap: () async {
                        // text prompt
                        if (!_promptController.text.isEmpty) {
                          FocusScope.of(context).unfocus();
                          _promptController.text = '';
                          await _hitApi(prompt);
                        }
                        // audio prompt
                        else {
                          if (await _speechToText.hasPermission &&
                              !_speechToText.isListening) {
                            await _startRecording();
                            await _hitApi(prompt);
                          } else if (_speechToText.isListening) {
                            await _stopRecording();
                          } else {
                            await initSTT();
                          }
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: CircleAvatar(
                          backgroundColor: Pallete.firstSuggestionBoxColor,
                          child: Icon(_promptController.text.trim().isEmpty
                              ? Icons.mic
                              : Icons.send),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_recognition_result.dart';
// import 'package:speech_to_text/speech_to_text.dart';
// import 'package:voice_assistant_with_ai/colors.dart';
// import 'package:voice_assistant_with_ai/gemeni_services.dart';
//
// class Homescreen extends StatefulWidget {
//   const Homescreen({super.key});
//
//   @override
//   State<Homescreen> createState() => _HomescreenState();
// }
//
// class _HomescreenState extends State<Homescreen> {
//   SpeechToText _speechToText = SpeechToText();
//
//   bool isLoading = false;
//   String prompt = 'Hello World';
//   String gemeniResponse = 'Good Morning! What can I do for you?';
//
//   final _promptController = TextEditingController();
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     initSTT();
//   }
//
//   Future<void> initSTT() async {
//     await _speechToText.initialize();
//     setState(() {});
//   }
//
//   Future<void> _startRecording() async {
//     print('start recording is called');
//
//     await _speechToText.listen(onResult: _speechResult);
//   }
//
//   Future<void> _speechResult(SpeechRecognitionResult voice) async {
//     prompt = voice.recognizedWords;
//     _promptController.text = voice.recognizedWords;
//     setState(() {});
//     print('hello');
//   }
//
//   Future<void> _stopRecording() async {
//     print('stop recording is called');
//     await _speechToText.stop();
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     _speechToText.stop();
//   }
//
//   Future<void> _hitApi(String prompt) async {
//     setState(() {
//       isLoading = true;
//     });
//     gemeniResponse = await GemeniServices().isImage(prompt);
//
//     setState(() {
//       isLoading = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(
//           'Voice Assistant',
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: () {
//               setState(() {});
//               _hitApi(prompt);
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text(
//                 // 'Voice Assistant',
//                 prompt.toString(),
//                 style: TextStyle(
//                   fontSize: 30,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               Stack(
//                 children: [
//                   Center(
//                     child: Container(
//                       height: 120,
//                       width: 120,
//                       margin: EdgeInsets.only(top: 8),
//                       decoration: BoxDecoration(
//                         color: Pallete.assistantCircleColor,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   ),
//                   Container(
//                     height: 125,
//                     decoration: BoxDecoration(
//                       image: DecorationImage(
//                         image: AssetImage('assets/images/virtualAssistant.png'),
//                       ),
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ],
//               ),
//               Container(
//                 width: double.infinity,
//                 margin: EdgeInsets.only(
//                   top: 20,
//                   bottom: 16,
//                   left: 10,
//                   right: 10,
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: Pallete.borderColor,
//                   ),
//                   borderRadius: BorderRadius.circular(20).copyWith(
//                     topLeft: Radius.zero,
//                   ),
//                 ),
//                 child: SizedBox(
//                   height: 200,
//                   child: isLoading
//                       ? Text('Generating...')
//                       : ListView(
//                           children: [
//                             Text(
//                               gemeniResponse.toString(),
//                               style: TextStyle(
//                                 fontFamily: 'Cera Pro',
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ],
//                         ),
//                 ),
//               ),
//               // Align(
//               //   alignment: Alignment.centerLeft,
//               //   child: Text(
//               //     'Here a few features',
//               //     style: TextStyle(
//               //       fontFamily: 'Cera Pro',
//               //       fontSize: 23,
//               //       fontWeight: FontWeight.w500,
//               //     ),
//               //   ),
//               // ),
//               // FeatureBox(
//               //   title: 'ChatGPT',
//               //   description: 'A smarter way to access ChatGPT.',
//               //   color: Pallete.firstSuggestionBoxColor,
//               // ),
//               // FeatureBox(
//               //   title: 'Dall-E',
//               //   description: 'A smarter way to access Dall-E.',
//               //   color: Pallete.secondSuggestionBoxColor,
//               // ),
//               // FeatureBox(
//               //   title: 'Smart Voice Assistant',
//               //   description: 'A smarter way to access Smart Voice Assistant.',
//               //   color: Pallete.firstSuggestionBoxColor,
//               // ),
//               // ElevatedButton(
//               //   onPressed: () async {
//               //     await _hitApi(prompt);
//               //   },
//               //   child: Text('Gemeni'),
//               // ),
//               SizedBox(
//                 height: 150,
//               ),
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: Padding(
//                   padding: EdgeInsets.only(bottom: 6),
//                   child: TextField(
//                     controller: _promptController,
//                     onChanged: (e) {
//                       prompt = e;
//                       // to change icon
//                       setState(() {});
//                     },
//                     decoration: InputDecoration(
//                       suffixIcon: InkWell(
//                         onTap: () async {
//                           // text prompt
//                           if (!_promptController.text.isEmpty) {
//                             FocusScope.of(context).unfocus();
//                             await _hitApi(prompt);
//                           }
//                           // audio prompt
//                           else {
//                             if (await _speechToText.hasPermission &&
//                                 !_speechToText.isListening) {
//                               await _startRecording();
//                               await _hitApi(prompt);
//                             } else if (_speechToText.isListening) {
//                               await _stopRecording();
//                             } else {
//                               await initSTT();
//                             }
//                           }
//                         },
//                         child: Padding(
//                           padding: EdgeInsets.all(10),
//                           child: CircleAvatar(
//                             backgroundColor: Pallete.firstSuggestionBoxColor,
//                             child: Icon(_promptController.text.trim().isEmpty
//                                 ? Icons.mic
//                                 : Icons.send),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
