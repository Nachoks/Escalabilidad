import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener intl o usa tu formateador
import 'package:somnolence_app/features/rendiciones/data/models/rendicion_model.dart';
import 'package:somnolence_app/features/rendiciones/data/models/gasto_model.dart';

class RendicionPdfBuilder {
  // Función principal que llama la UI
  static Future<void> imprimirRendicion(
    RendicionModel rendicion,
    List<GastoModel> gastos,
  ) async {
    final pdf = pw.Document();

    // Formateador de dinero simple
    final currencyFormat = NumberFormat.currency(locale: 'es_CL', symbol: '\$');

    // Calculamos el total gastado
    int totalGastado = gastos.fold(0, (sum, item) => sum + item.monto);
    int saldo = rendicion.montoEntregado - totalGastado;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // --- 1. TÍTULO ---
            pw.Header(
              level: 0,
              child: pw.Center(
                child: pw.Text(
                  "RENDICIÓN DE GASTOS",
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // --- 2. CABECERA DE DATOS ---
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildDataRow("ID Rendición:", "#${rendicion.idRendicion}"),
                  _buildDataRow("Fecha:", rendicion.fecha),
                  _buildDataRow("Responsable:", rendicion.nombreUsuario),
                  _buildDataRow("Propósito:", rendicion.proposito),
                  pw.Divider(),
                  _buildDataRow(
                    "Monto Asignado:",
                    currencyFormat.format(rendicion.montoEntregado),
                    isBold: true,
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // --- 3. TABLA DE GASTOS ---
            pw.Text(
              "Detalle de Gastos",
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),

            pw.Table.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
              ),
              headerHeight: 25,
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerRight,
              },
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: const pw.TextStyle(fontSize: 10),
              headers: <String>['Fecha', 'Detalle', 'Documento', 'Monto'],
              data: gastos.map((g) {
                return [
                  g.fecha,
                  g.detalle,
                  "${g.tipoDocumento} ${g.numDocumento ?? ''}",
                  currencyFormat.format(g.monto),
                ];
              }).toList(),
            ),

            pw.SizedBox(height: 20),

            // --- 4. TOTALES AL FINAL ---
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      "Total Gastado: ${currencyFormat.format(totalGastado)}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      saldo < 0
                          ? "Reembolso a Usuario: ${currencyFormat.format(saldo.abs())}"
                          : "Devolución a Empresa: ${currencyFormat.format(saldo)}",
                      style: pw.TextStyle(
                        color: saldo < 0 ? PdfColors.red : PdfColors.green,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    // Abrir vista previa de impresión (Android/iOS/Web)
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Rendicion_${rendicion.idRendicion}.pdf',
    );
  }

  // Helper para filas de datos
  static pw.Widget _buildDataRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey700)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
