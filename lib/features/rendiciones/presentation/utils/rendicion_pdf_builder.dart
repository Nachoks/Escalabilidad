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
  // --- 1. Generar Bytes del PDF (Para enviar al Backend o Imprimir) ---
  static Future<Uint8List> generarBytes({
    required RendicionModel rendicion,
    required List<GastoModel> gastos,
  }) async {
    final pdf = pw.Document();

    // A. Cargar Logo
    final logoImage = await imageFromAssetBundle('assets/images/icon.png');

    // B. Formatos
    final numberFormat = NumberFormat.decimalPattern('es_CL');
    String fmtMoney(int amount) => "\$ ${numberFormat.format(amount)}";

    // CORRECCIÓN: Ahora usamos esta variable en el encabezado
    final String fechaReporte = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(DateTime.now());

    // C. Cálculos
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
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Logo
                  pw.Container(
                    width: 50,
                    height: 50,
                    child: pw.Image(logoImage),
                  ),
                  pw.SizedBox(width: 15),

                  // Título
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "COMPROBANTE DE RENDICIÓN",
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          "Escalabilidad E.I.R.L.", // O el nombre de tu empresa
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Fecha de Reporte (AQUÍ USAMOS LA VARIABLE)
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "Fecha Emisión:",
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        fechaReporte,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Datos Generales
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                children: [
                  _buildDataRow("ID Rendición:", "#${rendicion.idRendicion}"),
                  _buildDataRow("Responsable:", rendicion.nombreUsuario),
                  _buildDataRow("Propósito:", rendicion.proposito),
                  pw.Divider(color: PdfColors.grey300),
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
                fontSize: 9,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headers: <String>['Fecha', 'Detalle', 'Tipo', 'Doc.', 'Monto'],
              data: gastos.map((g) {
                return [
                  g.fecha, // Asumimos que viene formateada dd-mm-yyyy o yyyy-mm-dd
                  g.detalle,
                  g.tipoDocumento,
                  g.numDocumento ?? 'S/N',
                  fmtMoney(g.monto),
                ];
              }).toList(),
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
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    // --- SECCIÓN 2: EVIDENCIA FOTOGRÁFICA Y DOCUMENTOS ---
    for (final gasto in gastos) {
      if (gasto.fotos.isEmpty) continue;

      for (final archivo in gasto.fotos) {
        try {
          final String extension = archivo.extension?.toLowerCase() ?? '';
          final bool esImagen = [
            'jpg',
            'jpeg',
            'png',
            'gif',
            'webp',
          ].contains(extension);
          final bool esPdf = extension == 'pdf';

          // Normalizamos ruta para evitar dobles slash
          String rutaLimpia = archivo.rutaRelativa.replaceAll('\\', '/');
          if (rutaLimpia.startsWith('/')) rutaLimpia = rutaLimpia.substring(1);

          final String imageUrl = '${ApiService.baseUrl}/evidencia/$rutaLimpia';

          if (esPdf) {
            // === PDF: Crear página con información del documento ===
            // Los PDFs no se pueden incrustar como imagen, pero creamos una página de referencia
            pdf.addPage(
              pw.Page(
                pageFormat: PdfPageFormat.a4,
                margin: const pw.EdgeInsets.all(40),
                build: (pw.Context context) {
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      pw.Header(
                        level: 1,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              "ANEXO - DOCUMENTO ADJUNTO",
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.red700,
                              ),
                            ),
                            pw.Text(
                              "ID Gasto: ${gasto.idGasto}",
                              style: const pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 30),

                      // Caja con información del documento PDF
                      pw.Container(
                        padding: const pw.EdgeInsets.all(20),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                            color: PdfColors.red300,
                            width: 2,
                          ),
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(8),
                          ),
                          color: PdfColors.red50,
                        ),
                        child: pw.Column(
                          children: [
                            // Icono de PDF (usando texto como representación)
                            pw.Container(
                              width: 80,
                              height: 80,
                              decoration: pw.BoxDecoration(
                                color: PdfColors.red100,
                                borderRadius: const pw.BorderRadius.all(
                                  pw.Radius.circular(8),
                                ),
                              ),
                              child: pw.Center(
                                child: pw.Text(
                                  "PDF",
                                  style: pw.TextStyle(
                                    fontSize: 24,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.red700,
                                  ),
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 16),
                            pw.Text(
                              "Documento Adjunto",
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.red800,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text(
                              archivo.nombreOriginal ?? 'Documento PDF',
                              style: const pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.SizedBox(height: 20),
                            pw.Divider(color: PdfColors.red200),
                            pw.SizedBox(height: 20),

                            // Información del gasto
                            pw.Container(
                              width: double.infinity,
                              padding: const pw.EdgeInsets.all(12),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.grey100,
                                borderRadius: const pw.BorderRadius.all(
                                  pw.Radius.circular(4),
                                ),
                              ),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _buildDataRowPdf("Gasto:", gasto.detalle),
                                  _buildDataRowPdf(
                                    "Monto:",
                                    fmtMoney(gasto.monto),
                                  ),
                                  _buildDataRowPdf(
                                    "Tipo Documento:",
                                    gasto.tipoDocumento ?? 'N/A',
                                  ),
                                  _buildDataRowPdf(
                                    "N° Documento:",
                                    gasto.numDocumento ?? 'Sin número',
                                  ),
                                  _buildDataRowPdf(
                                    "Archivo:",
                                    rutaLimpia.split('/').last,
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 20),
                            pw.Container(
                              padding: const pw.EdgeInsets.all(12),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.blue50,
                                borderRadius: const pw.BorderRadius.all(
                                  pw.Radius.circular(4),
                                ),
                              ),
                              child: pw.Row(
                                children: [
                                  pw.Icon(
                                    const pw.IconData(0xe88a), // info icon
                                    size: 16,
                                    color: PdfColors.blue700,
                                  ),
                                  pw.SizedBox(width: 8),
                                  pw.Expanded(
                                    child: pw.Text(
                                      "Para ver este documento, consulte la evidencia digital en la aplicación.",
                                      style: const pw.TextStyle(
                                        fontSize: 10,
                                        color: PdfColors.blue700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          } else if (esImagen) {
            // === IMAGEN: Incrustar normalmente ===
            final response = await http.get(Uri.parse(imageUrl));

            if (response.statusCode == 200) {
              final Uint8List imageBytes = response.bodyBytes;
              final imageProvider = pw.MemoryImage(imageBytes);

              pdf.addPage(
                pw.Page(
                  pageFormat: PdfPageFormat.a4,
                  margin: const pw.EdgeInsets.all(40),
                  build: (pw.Context context) {
                    return pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        pw.Header(
                          level: 1,
                          child: pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                "ANEXO - EVIDENCIA",
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.grey700,
                                ),
                              ),
                              pw.Text(
                                "ID Gasto: ${gasto.idGasto}",
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColors.grey500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 20),

                        // Información del Gasto asociado a la imagen
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          color: PdfColors.grey100,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                "Gasto: ${gasto.detalle}",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text("Monto: ${fmtMoney(gasto.monto)}"),
                              pw.Text(
                                "Documento: ${gasto.tipoDocumento} ${gasto.numDocumento ?? ''}",
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 20),

                        // Imagen
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
            }
          }
          // Otros tipos de archivo se ignoran
        } catch (e) {
          print("Error agregando evidencia al PDF: $e");
        }
      }
    }

    return pdf.save();
  }

  // --- 2. Método para Imprimir/Compartir desde el celular ---
  static Future<void> imprimirRendicion(
    RendicionModel rendicion,
    List<GastoModel> gastos,
  ) async {
    final bytes = await generarBytes(rendicion: rendicion, gastos: gastos);

    final String fechaNombre = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final String nombreArchivo =
        'Rendicion_${rendicion.idRendicion}_$fechaNombre.pdf';

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: nombreArchivo,
    );
  }

  // --- Widgets Auxiliares ---
  static pw.Widget _buildDataRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Auxiliar para Filas de PDF en Reporte ---
  static pw.Widget _buildDataRowPdf(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
