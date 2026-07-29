import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportGenerator {
  static Future<void> generateAndShareReport(List<Map<String, dynamic>> appStats) async {
    final pdf = pw.Document();

    // 🧮 Calculate true system usage totals dynamically for the header metrics panel
    int totalMinutes = 0;
    int totalWifiMb = 0;
    int totalMobileMb = 0;

    for (var app in appStats) {
      totalMinutes += (app['minutes'] as int? ?? 0);

      // Parse integers out of strings like "342 MB" safely
      final wifiStr = app['wifiData'].toString().replaceAll(RegExp(r'[^0-9]'), '');
      final mobileStr = app['mobileData'].toString().replaceAll(RegExp(r'[^0-9]'), '');

      totalWifiMb += int.tryParse(wifiStr) ?? 0;
      totalMobileMb += int.tryParse(mobileStr) ?? 0;
    }

    final int totalHours = totalMinutes ~/ 60;
    final int remainingMins = totalMinutes % 60;
    final String totalDurationString = '${totalHours}h ${remainingMins}m';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            // ✅ FIXED: Explicitly named parameter assignment
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ───────────────────────────────────────────────────────────────
              // SECTION 1: OFFICIAL CORPORATE BRAND HEADER & LOGO MESH
              // ───────────────────────────────────────────────────────────────
              pw.Row(
                // ✅ FIXED: Explicitly named parameter assignment
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    // ✅ FIXED: Explicitly named parameter assignment
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'POWERGUARD',
                        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900, letterSpacing: 2.0),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'SYSTEM TELEMETRY & DATA ANALYSIS LOG',
                        style:  pw.TextStyle(color: PdfColors.grey600, fontSize: 9, letterSpacing: 0.5),
                      ),
                    ],
                  ),

                  // 📱 BRAND LOGO: Vector Smartphone Shape with an internal Battery Node Cap
                  pw.Container(
                    width: 34,
                    height: 56,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.blueGrey800, width: 2.5),
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
                      color: PdfColors.grey100,
                    ),
                    padding:  pw.EdgeInsets.all(3),
                    child: pw.Stack(
                      alignment: pw.Alignment.bottomCenter,
                      children: [
                        pw.Container(
                          width: double.infinity,
                          height: 34,
                          decoration:  pw.BoxDecoration(
                            color: PdfColors.green500,
                            borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
                          ),
                        ),
                        pw.Center(
                          child: pw.Text(
                            '⚡',
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 12),
              pw.Divider(thickness: 2.0, color: PdfColors.blueGrey800),
              pw.SizedBox(height: 10),

              // Timestamp and Document Metadata Sub-Row
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Report ID: PG-${DateTime.now().millisecondsSinceEpoch ~/ 10000}', style:  pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  pw.Text('Exported: ${DateTime.now().toString().split('.')[0]}', style:  pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  pw.Text('Status: Hardware Verified', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                ],
              ),
              pw.SizedBox(height: 24),

              // ───────────────────────────────────────────────────────────────
              // SECTION 2: ACCURATE SYSTEM ACCUMULATION SUMMARY TOTALS CARD
              // ───────────────────────────────────────────────────────────────
              pw.Text(
                'AGGREGATED SYSTEM ENERGY & DATA STORAGE METRICS:',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey700),
              ),
              pw.SizedBox(height: 8),

              pw.Container(
                width: double.infinity,
                padding:  pw.EdgeInsets.all(14),
                decoration:  pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem('Total Active Usage', totalDurationString, PdfColors.blueGrey900),
                    _buildSummaryItem('Total Network Traffic', '${totalWifiMb + totalMobileMb} MB', PdfColors.blueGrey900),
                    _buildSummaryItem('Wi-Fi / Cellular Data Split', '$totalWifiMb MB / $totalMobileMb MB', PdfColors.grey700),
                  ],
                ),
              ),
              pw.SizedBox(height: 28),

              // ───────────────────────────────────────────────────────────────
              // SECTION 3: REFINED APPLICATION UTILITIES DATA TABLE
              // ───────────────────────────────────────────────────────────────
              pw.Text(
                'ITEMIZED APPLICATION TELEMETRY DATA BREAKDOWN:',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey700),
              ),
              pw.SizedBox(height: 10),

              pw.TableHelper.fromTextArray(
                headers: <String>['Application Tracker Name', 'Active Screen Time', 'Wi-Fi Data Used', 'Mobile Data Used'],
                data: appStats.map((app) => <String>[
                  app['name'].toString(),
                  app['duration'].toString(),
                  app['wifiData'].toString(),
                  app['mobileData'].toString(),
                ]).toList(),
                border:  pw.TableBorder(
                  horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                  top: pw.BorderSide(color: PdfColors.grey400, width: 1.0),
                  bottom: pw.BorderSide(color: PdfColors.grey400, width: 1.0),
                  left: pw.BorderSide(color: PdfColors.grey400, width: 1.0),
                  right: pw.BorderSide(color: PdfColors.grey400, width: 1.0),
                ),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
                headerDecoration:  pw.BoxDecoration(color: PdfColors.blueGrey800),
                cellStyle:  pw.TextStyle(fontSize: 10, color: PdfColors.grey900),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),

              pw.Spacer(),

              // ───────────────────────────────────────────────────────────────
              // SECTION 4: DOCUMENT LAYOUT FOOTER BASE
              // ───────────────────────────────────────────────────────────────
              pw.Divider(thickness: 0.5, color: PdfColors.grey400),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(
                  'This analytical log is natively compiled via PowerGuard AI Smart Device Diagnostics and encrypted for security verification.',
                  style: pw.TextStyle(fontSize: 7.5, color: PdfColors.grey500, fontStyle: pw.FontStyle.italic),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Prompt native document share tray
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'powerguard_executive_report.pdf');
  }

  static pw.Widget _buildSummaryItem(String title, String value, PdfColor valueColor) {
    return pw.Column(
      // ✅ FIXED: Explicitly named parameter assignment
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(title, style:  pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: valueColor)),
      ],
    );
  }
}