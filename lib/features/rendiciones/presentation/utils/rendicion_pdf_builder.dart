import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:somnolence_app/features/rendiciones/data/models/rendicion_model.dart';
import 'package:somnolence_app/features/rendiciones/data/models/gasto_model.dart';

class RendicionPdfBuilder {
  static Future<void> imprimirRendicion(
    RendicionModel rendicion,
    List<GastoModel> gastos,
  ) async {
    final pdf = pw.Document();

    // 1. CARGAR IMAGEN DEL LOGO
    // Asegúrate de que 'assets/images/icon.png' esté declarado en tu pubspec.yaml
    final logoImage = await imageFromAssetBundle('assets/images/icon.png');

    // 2. FORMATO NUMÉRICO BASE
    final numberFormat = NumberFormat.decimalPattern('es_CL');

    String fmtMoney(int amount) {
      return "\$ ${numberFormat.format(amount)}";
    }

    final String fechaReporte = DateFormat('dd/MM/yyyy').format(DateTime.now());

    int totalGastado = gastos.fold(0, (sum, item) => sum + item.monto);
    int saldo = rendicion.montoEntregado - totalGastado;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // TÍTULO CON LOGO
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Logo a la izquierda
                  pw.Container(
                    width: 60,
                    height: 60,
                    child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                  ),

                  // Título centrado (Usamos Expanded para que ocupe el espacio central)
                  pw.Expanded(
                    child: pw.Center(
                      child: pw.Text(
                        "COMPROBANTE DE RENDICIÓN",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize:
                              18, // Ajusté un poco el tamaño para que quepa bien
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Espaciador invisible a la derecha del mismo ancho que el logo
                  // para asegurar que el título quede matemáticamente centrado
                  pw.SizedBox(width: 60),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // DATOS DE LA RENDICIÓN
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
                  _buildDataRow("Fecha Emisión:", fechaReporte),
                  _buildDataRow("Responsable:", rendicion.nombreUsuario),
                  _buildDataRow("Propósito:", rendicion.proposito),
                  pw.Divider(),
                  _buildDataRow(
                    "Monto Asignado:",
                    fmtMoney(rendicion.montoEntregado),
                    isBold: true,
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // 3. TABLA DE GASTOS
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
                3: pw.Alignment.centerLeft,
                4: pw.Alignment.centerRight,
              },
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: const pw.TextStyle(fontSize: 10),
              headers: <String>['Fecha', 'Detalle', 'Tipo', 'N° Doc.', 'Monto'],
              data: gastos.map((g) {
                return [
                  g.fecha,
                  g.detalle,
                  g.tipoDocumento,
                  g.numDocumento ?? 'S/N',
                  fmtMoney(g.monto),
                ];
              }).toList(),
            ),

            pw.SizedBox(height: 20),

            // 4. TOTALES
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      "Total Gastado: ${fmtMoney(totalGastado)}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      saldo < 0
                          ? "Reembolso a Usuario: ${fmtMoney(saldo.abs())}"
                          : "Devolución a Empresa: ${fmtMoney(saldo)}",
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

    final String nombreArchivo =
        'Rendicion_${rendicion.idRendicion}_$fechaReporte.pdf'.replaceAll(
          '/',
          '-',
        );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: nombreArchivo,
    );
  }

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
