import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';

class PDFViewerScreen extends StatelessWidget {
  final PDFDocument document;

  const PDFViewerScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PDFViewer(
          document: document,
        )
    );
  }
}
