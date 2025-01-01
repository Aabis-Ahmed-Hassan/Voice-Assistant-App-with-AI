import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:voice_assistant_with_ai/colors.dart';

class SingleMessage extends StatelessWidget {
  SingleMessage(
      {super.key, required this.message, required this.isUserMessage});

  String message;
  bool isUserMessage;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return isUserMessage ? UserMessage(context) : GemeniResponse(context);
  }

  Widget UserMessage(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: height * 0.005,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            alignment: Alignment.centerRight,
            constraints: BoxConstraints(
              maxWidth: width * 0.65,
            ),
            padding: EdgeInsets.symmetric(
                horizontal: height * 0.0125, vertical: height * 0.0125),
            decoration: BoxDecoration(
              color: Pallete.firstSuggestionBoxColor,
              border: Border.all(
                color: Colors.black.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
            ),
            // child: Text(
            //   message.toString(),
            //   style: TextStyle(fontSize: 16),
            // ),
            child: MarkdownBody(data: message),
          )
        ],
      ),
    );
  }

  Widget GemeniResponse(BuildContext context) {
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
            // child: Text(
            //   message.toString(),
            //   style: TextStyle(fontSize: 16),
            // ),
            // child: BoldTextParser(message),
            child: MarkdownBody(data: message),
          ),
        ],
      ),
    );
  }
}

class BoldTextParser extends StatelessWidget {
  final String text;

  BoldTextParser(this.text);

  @override
  Widget build(BuildContext context) {
    List<TextSpan> spans = [];
    RegExp exp = RegExp(r'\*\*(.*?)\*\*');
    Iterable<Match> matches = exp.allMatches(text);
    int lastMatchEnd = 0;

    for (Match match in matches) {
      // Add the normal text before the bold text
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: TextStyle(color: Colors.black),
        ));
      }
      // Add the bold text
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(fontWeight: FontWeight.bold),
      ));
      lastMatchEnd = match.end;
    }

    // Add the remaining normal text
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: TextStyle(color: Colors.black),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
