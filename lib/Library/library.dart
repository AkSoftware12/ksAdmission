

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  final String htmlContent = """
  <div class="elibrary-container">
      <h2 class="title">E-Library – Coming Soon!</h2>

      <h3 class="subtitle">Unlock Unlimited Learning with KS Admission’s E-Library!</h3>

      <p class="description">
          We are excited to introduce the <strong>E-Library</strong> feature in our app, where students across India can access Government books for <strong>FREE</strong>! 
          Whether you're a Class 11th-12th student, a NEET aspirant, or preparing for other Entrance exams, our E-Library has everything you need.
      </p>

      <ul class="features">
          <li>Access a vast collection of books for <strong>NEET, CUET, BSc Nursing</strong>, and other exams.</li>
          <li><strong>Completely FREE</strong> for all students across India!</li>
          <li>Study anytime, anywhere with digital access.</li>
          <li>Perfect for <strong>NCERT (All State Board, CBSE, ICSE Board)</strong>-based learning & competitive exam prep.</li>
      </ul>

      <h3 class="coming-soon">Coming Soon – Stay Tuned!</h3>
  </div>
  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Html(
            data: htmlContent,
            style: {
              "h2": Style(
                fontSize: FontSize.xLarge,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
                textAlign: TextAlign.center,
              ),
              "h3": Style(
                fontSize: FontSize.large,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
                textAlign: TextAlign.center,
              ),
              "p": Style(
                fontSize: FontSize.large,
                color: Colors.black87,
                textAlign: TextAlign.center,
              ),
              "ul": Style(
                fontSize: FontSize.large,
                padding: HtmlPaddings.all(8),
                color: Colors.black87,
              ),
              "li": Style(
                fontSize: FontSize.large,
                color: Colors.black87,
              ),
            },
          ),
        ),
      ),
    );
  }
}
