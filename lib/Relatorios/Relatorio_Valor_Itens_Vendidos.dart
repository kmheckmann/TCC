import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:pdf/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart' as material;
import 'package:tcc_3/acessorios/PDFViewerPage.dart';

reportView_Valor_Itens_Vendidos(
    context, DateTime data1, DateTime data2, List<List<String>> lista) async {
  final Document pdf = Document();

  pdf.addPage(MultiPage(
      pageFormat:
          PdfPageFormat.letter.copyWith(marginBottom: 1.0 * PdfPageFormat.cm),
      crossAxisAlignment: CrossAxisAlignment.start,
      header: (Context context) {
        if (context.pageNumber == 1) {
          return null;
        }
        return Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(bottom: 0.5 * PdfPageFormat.mm),
            padding: const EdgeInsets.only(bottom: 0.5 * PdfPageFormat.mm),
            decoration: BoxDecoration(
                border:
                    BoxBorder(bottom: true, width: 0.5, color: PdfColors.grey)),
            child: Text('Itens por Cliente',
                style: Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColors.grey)));
      },
      footer: (Context context) {
        return Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: Text('Page ${context.pageNumber} of ${context.pagesCount}',
                style: Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColors.black)));
      },
      build: (Context context) => <Widget>[
            Header(
                level: 0,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Valor obtido por venda de itens",
                          textScaleFactor: 1, style: TextStyle(fontSize: 23.0)),
                    ])),
            Padding(padding: const EdgeInsets.all(3)),
            Paragraph(
                text: 'De: ' +
                    data1.day.toString() +
                    '/' +
                    data1.month.toString() +
                    '/' +
                    data1.year.toString() +
                    " até: " +
                    data2.day.toString() +
                    '/' +
                    data2.month.toString() +
                    '/' +
                    data2.year.toString(),
                style: TextStyle(fontSize: 17.0)),
            Header(level: 1, text: 'Itens'),
            Padding(padding: const EdgeInsets.all(1)),
            Table.fromTextArray(context: context, data: lista),
          ]));
  //save PDF

  final String dir = (await getApplicationDocumentsDirectory()).path;
  final String path = '$dir/report.pdf';
  final File file = File(path);
  await file.writeAsBytes(pdf.save());
  material.Navigator.of(context).push(
    material.MaterialPageRoute(
      builder: (_) => PdfViewerPage(path: path),
    ),
  );
}
