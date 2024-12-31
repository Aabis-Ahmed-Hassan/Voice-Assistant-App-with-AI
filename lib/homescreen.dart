import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_assistant_with_ai/colors.dart';
import 'package:voice_assistant_with_ai/gemeni_services.dart';
import 'package:voice_assistant_with_ai/single_message.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  SpeechToText _speechToText = SpeechToText();

  bool isLoading = false;
  String prompt = 'Hello World';
  String gemeniResponse = 'Hey! What can I do for you?';

  ScrollController _scrollController = ScrollController();

  FlutterTts _tts = FlutterTts();

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
    // _promptController.selection = TextSelection(
    //     baseOffset: 0, extentOffset: _promptController.value.text.length);

    setState(() {});
    if (!_speechToText.isListening && prompt.isNotEmpty) {
      await _hitApi(prompt);
    }
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
    _tts.stop();
  }

  Future<void> _hitApi(String prompt) async {
    setState(() {
      isLoading = true;
    });
    addMessage(prompt, true);
    gemeniResponse = await GemeniServices().isImage(prompt);
    addMessage(gemeniResponse, false);

    setState(() {
      isLoading = false;
    });
    speakTheResponse(gemeniResponse);
  }

  void speakTheResponse(String response) async {
    await _tts.speak(response);
  }

  List<Map<String, dynamic>> messages = [];

  void addMessage(String message, bool isUserMessage) {
    messages
        .add({'message': message, 'role': isUserMessage ? 'user' : 'model'});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 500), curve: Curves.linear);
      }
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
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
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
                child:
                    // isLoading
                    //     ? TypingIndicator()
                    //     :

                    messages.isEmpty
                        ? Text('Hey, How can I assist you?')
                        : ListView.builder(
                            shrinkWrap: true,
                            controller: _scrollController,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              // show a loading while data is being fetched from the api
                              if (isLoading && index == messages.length - 1) {
                                return Column(
                                  children: [
                                    SingleMessage(
                                        message: messages[index]['message'],
                                        isUserMessage:
                                            messages[index]['role'] == 'user'),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: TypingIndicator(),
                                    ),
                                  ],
                                );
                              }
                              return SingleMessage(
                                  message: messages[index]['message'],
                                  isUserMessage:
                                      messages[index]['role'] == 'user');
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _tts.stop();

          if (await _speechToText.hasPermission && !_speechToText.isListening) {
            await _startRecording();

            // await _hitApi(prompt);
          } else if (_speechToText.isListening) {
            await _stopRecording();
          } else {
            await initSTT();
          }
        },
        backgroundColor: Pallete.firstSuggestionBoxColor,
        child: Icon(Icons.mic),
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({Key? key}) : super(key: key);

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: height * 0.005,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            constraints: BoxConstraints(maxWidth: width * 0.65),
            padding: EdgeInsets.symmetric(
                horizontal: height * 0.0125, vertical: height * 0.0125),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black.withOpacity(0.5),
              ),
              color: Pallete.secondSuggestionBoxColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: SizedBox(
              width: 50,
              height: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Opacity(
                        opacity:
                            (_animation.value - (index * 0.3)).clamp(0.0, 1.0),
                        child: Center(
                          child: Container(
                            alignment: Alignment.topLeft,
                            width: 8,
                            height: 8,
                            margin: EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
    // return SizedBox(
    //   width: 50,
    //   height: 20,
    //   child: Row(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     mainAxisAlignment: MainAxisAlignment.start,
    //     children: List.generate(3, (index) {
    //       return AnimatedBuilder(
    //         animation: _animation,
    //         builder: (context, child) {
    //           return Opacity(
    //             opacity: (_animation.value - (index * 0.3)).clamp(0.0, 1.0),
    //             child: Container(
    //               alignment: Alignment.topLeft,
    //               width: 8,
    //               height: 8,
    //               margin: EdgeInsets.only(right: 8),
    //               decoration: BoxDecoration(
    //                 color: Pallete.secondSuggestionBoxColor,
    //                 shape: BoxShape.circle,
    //               ),
    //             ),
    //           );
    //         },
    //       );
    //     }),
    //   ),
    // );
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:speech_to_text/speech_recognition_result.dart';
// import 'package:speech_to_text/speech_to_text.dart';
// import 'package:voice_assistant_with_ai/colors.dart';
// import 'package:voice_assistant_with_ai/gemeni_services.dart';
// import 'package:voice_assistant_with_ai/single_message.dart';
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
//   String gemeniResponse = 'Hey! What can I do for you?';
//
//   final _promptController = TextEditingController();
//   ScrollController _scrollController = ScrollController();
//
//   FlutterTts _tts = FlutterTts();
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     initSTT();
//   }
//
//   Future<void> initSTT() async {
//     await _speechToText.initialize();
//
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
//     // _promptController.selection = TextSelection(
//     //     baseOffset: 0, extentOffset: _promptController.value.text.length);
//
//     setState(() {});
//     if (!_speechToText.isListening && prompt.isNotEmpty) {
//       await _hitApi(prompt);
//     }
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
//     _tts.stop();
//   }
//
//   Future<void> _hitApi(String prompt) async {
//     addMessage(prompt, true);
//     setState(() {
//       isLoading = true;
//     });
//     gemeniResponse = await GemeniServices().isImage(prompt);
//     addMessage(gemeniResponse, false);
//
//     setState(() {
//       isLoading = false;
//     });
//     speakTheResponse(gemeniResponse);
//   }
//
//   void speakTheResponse(String response) async {
//     await _tts.speak(response);
//   }
//
//   List<Map<String, dynamic>> messages = [];
//   void addMessage(String message, bool isUserMessage) {
//     messages
//         .add({'message': message, 'role': isUserMessage ? 'user' : 'model'});
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(_scrollController.position.maxScrollExtent,
//             duration: Duration(milliseconds: 500), curve: Curves.linear);
//       }
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
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Stack(
//             //   children: [
//             //     Center(
//             //       child: Container(
//             //         height: 120,
//             //         width: 120,
//             //         margin: EdgeInsets.only(top: 8),
//             //         decoration: BoxDecoration(
//             //           color: Pallete.assistantCircleColor,
//             //           shape: BoxShape.circle,
//             //         ),
//             //       ),
//             //     ),
//             //     Container(
//             //       height: 125,
//             //       decoration: BoxDecoration(
//             //         image: DecorationImage(
//             //           image: AssetImage('assets/images/virtualAssistant.png'),
//             //         ),
//             //         shape: BoxShape.circle,
//             //       ),
//             //     ),
//             //   ],
//             // ),
//             Container(
//               width: double.infinity,
//               margin: EdgeInsets.only(
//                 top: 20,
//                 bottom: 16,
//                 left: 10,
//                 right: 10,
//               ),
//               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: Pallete.borderColor,
//                 ),
//                 borderRadius: BorderRadius.circular(20).copyWith(
//                   topLeft: Radius.zero,
//                 ),
//               ),
//               child: SizedBox(
//                 height: 250,
//                 child: isLoading
//                     // ? Text('Generating...')
//                     ? TypingIndicator()
//                     : messages.isEmpty
//                         ? Text('Hey, How can I assist you?')
//                         : ListView.builder(
//                             shrinkWrap: true,
//                             controller: _scrollController,
//                             itemCount: messages.length,
//                             itemBuilder: (context, index) {
//                               return SingleMessage(
//                                   message: messages[index]['message'],
//                                   isUserMessage:
//                                       messages[index]['role'] == 'user');
//                             }),
//               ),
//             ),
//
//             Spacer(),
//             Padding(
//               padding: EdgeInsets.only(bottom: 6),
//               child: TextField(
//                 autofocus: true,
//                 keyboardType: TextInputType.multiline,
//                 controller: _promptController,
//                 onChanged: (e) {
//                   prompt = e;
//                   // to change icon
//                   setState(() {});
//                 },
//                 decoration: InputDecoration(
//                   hintText: 'Enter something...',
//                   suffixIcon: InkWell(
//                     onTap: () async {
//                       await _tts.stop();
//
//                       // text prompt
//                       if (!_promptController.text.isEmpty) {
//                         FocusScope.of(context).unfocus();
//                         _promptController.text = '';
//                         await _hitApi(prompt);
//                       }
//                       // audio prompt
//                       else {
//                         if (await _speechToText.hasPermission &&
//                             !_speechToText.isListening) {
//                           _promptController.text = '';
//                           await _startRecording();
//
//                           // await _hitApi(prompt);
//                         } else if (_speechToText.isListening) {
//                           await _stopRecording();
//                         } else {
//                           await initSTT();
//                         }
//                       }
//                     },
//                     child: Padding(
//                       padding: EdgeInsets.all(10),
//                       child: CircleAvatar(
//                         backgroundColor: Pallete.firstSuggestionBoxColor,
//                         child: Icon(_promptController.text.trim().isEmpty
//                             ? Icons.mic
//                             : Icons.send),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class TypingIndicator extends StatefulWidget {
//   const TypingIndicator({Key? key}) : super(key: key);
//
//   @override
//   _TypingIndicatorState createState() => _TypingIndicatorState();
// }
//
// class _TypingIndicatorState extends State<TypingIndicator>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = AnimationController(
//       duration: Duration(milliseconds: 1200),
//       vsync: this,
//     )..repeat();
//
//     _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     ));
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 50,
//       height: 20,
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: List.generate(3, (index) {
//           return AnimatedBuilder(
//             animation: _animation,
//             builder: (context, child) {
//               return Opacity(
//                 opacity: (_animation.value - (index * 0.3)).clamp(0.0, 1.0),
//                 child: Container(
//                   alignment: Alignment.topLeft,
//                   width: 8,
//                   height: 8,
//                   margin: EdgeInsets.only(right: 8),
//                   decoration: BoxDecoration(
//                     color: Pallete.secondSuggestionBoxColor,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               );
//             },
//           );
//         }),
//       ),
//     );
//   }
// }
