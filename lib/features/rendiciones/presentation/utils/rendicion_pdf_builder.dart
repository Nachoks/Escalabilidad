import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:somnolence_app/core/api/api_service.dart';
import 'package:somnolence_app/features/rendiciones/data/models/rendicion_model.dart';
import 'package:somnolence_app/features/rendiciones/data/models/gasto_model.dart';

class RendicionPdfBuilder {
  static Future<void> imprimirRendicion(
    RendicionModel rendicion,
    List<GastoModel> gastos,
  ) async {
    final pdf = pw.Document();

    // 1. Cargar Logo
    final logoImage = await imageFromAssetBundle('assets/images/icon.png');

    // 2. Formatos
    final numberFormat = NumberFormat.decimalPattern('es_CL');
    String fmtMoney(int amount) => "\$ ${numberFormat.format(amount)}";
    final String fechaReporte = DateFormat('dd/MM/yyyy').format(DateTime.now());

    // 3. Cálculos
    int totalGastado = gastos.fold(0, (sum, item) => sum + item.monto);
    int saldo = rendicion.montoEntregado - totalGastado;

    // --- PÁGINA 1: RESUMEN Y TABLA ---
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Encabezado
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Container(
                    width: 60,
                    height: 60,
                    child: pw.Image(logoImage),
                  ),
                  pw.Expanded(
                    child: pw.Center(
                      child: pw.Text(
                        "COMPROBANTE DE RENDICIÓN",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 60),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Datos Generales
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                children: [
                  _buildDataRow("ID Rendición:", "#${rendicion.idRendicion}"),
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

            // Tabla de Gastos
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
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: const pw.TextStyle(fontSize: 10),
              headers: <String>['Fecha', 'Detalle', 'Tipo', 'Doc.', 'Monto'],
              data: gastos
                  .map(
                    (g) => [
                      g.fecha,
                      g.detalle,
                      g.tipoDocumento,
                      g.numDocumento ?? 'S/N',
                      fmtMoney(g.monto),
                    ],
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 20),

            // Totales
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
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
            ),
          ];
        },
      ),
    );

    // --- SECCIÓN 2: EVIDENCIA FOTOGRÁFICA ---

    for (final gasto in gastos) {
      // Validamos si tiene fotos (usando tu modelo GastoModel y GastoArchivo)
      if (gasto.fotos.isEmpty) continue;

      for (final archivo in gasto.fotos) {
        try {
          final String imageUrl =
              '${ApiService.baseUrl}/evidencia/${archivo.rutaRelativa}';

          print("📥 Descargando imagen PDF: $imageUrl");

          final response = await http.get(Uri.parse(imageUrl));

          if (response.statusCode == 200) {
            final Uint8List imageBytes = response.bodyBytes;
            final imageProvider = pw.MemoryImage(imageBytes);

            // Nueva página por cada imagen
            pdf.addPage(
              pw.Page(
                pageFormat: PdfPageFormat.a4,
                margin: const pw.EdgeInsets.all(40),
                build: (pw.Context context) {
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      // Encabezado del Anexo
                      pw.Header(
                        level: 1,
                        child: pw.Text(
                          "ANEXO - EVIDENCIA DE GASTO",
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 20),

                      // Tarjeta con info del gasto
                      pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey100,
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(4),
                          ),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "Gasto: ${gasto.detalle}",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text("Fecha: ${gasto.fecha}"),
                            pw.Text("Monto: ${fmtMoney(gasto.monto)}"),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 20),

                      // La Imagen
                      pw.Expanded(
                        child: pw.Center(
                          child: pw.Image(
                            imageProvider,
                            fit: pw.BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          } else {
            print(
              "❌ Error al descargar imagen ($imageUrl): ${response.statusCode}",
            );
          }
        } catch (e) {
          print("🔥 Excepción al procesar imagen para PDF: $e");
        }
      }
    }

    // Guardar y Mostrar PDF
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
