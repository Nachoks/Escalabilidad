import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../data/models/hoja_tiempo_model.dart';

class HojaTiempoPdfBuilder {
  static Future<Uint8List> buildPdfDiario({
    required HojaTiempoSemana semana,
    required HojaTiempoDiaria dia,
    required String nombreUsuario,
  }) async {
    final pdf = pw.Document();

    // 1. Cargar LOGO
    final imageBytes = await rootBundle.load('assets/images/LOGO.png');
    final logoImage = pw.MemoryImage(imageBytes.buffer.asUint8List());

    // --- COLOR: Naranjo Corporativo (0xFFEF6C00) ---
    final PdfColor baseColor = PdfColor.fromInt(0xFFEF6C00);

    // Cálculos
    double sumHabiles = 0, sumNoHabiles = 0, sumFestivas = 0, sumTotal = 0;
    final actividades = dia.actividades ?? [];
    for (var act in actividades) {
      sumHabiles += act.horasHabiles;
      sumNoHabiles += act.horasNoHabiles;
      sumFestivas += act.horasFestivas;
    }
    sumTotal = sumHabiles + sumNoHabiles + sumFestivas;

    final dateFormat = DateFormat('dd-MM-yyyy');
    final fechaDia = dateFormat.format(dia.fecha);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => [
          _buildHeader(
            semana.nombreComprobante ?? 'BORRADOR',
            logoImage,
            baseColor,
          ),
          pw.SizedBox(height: 25),
          // Aquí pasamos el Centro de Costo (semana.centroCosto)
          _buildInfoSection(semana, dia, nombreUsuario, fechaDia, baseColor),
          pw.SizedBox(height: 30),
          _buildActivitiesTable(actividades, baseColor),
          pw.SizedBox(height: 15),
          _buildResumenTableHorizontal(
            sumHabiles,
            sumNoHabiles,
            sumFestivas,
            sumTotal,
            baseColor,
          ),
          pw.SizedBox(height: 40),
          _buildFooter(),
        ],
      ),
    );

    return pdf.save();
  }

  // --- 1. ENCABEZADO (Logo + Título + Código) ---
  static pw.Widget _buildHeader(
    String codigo,
    pw.MemoryImage logo,
    PdfColor color,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(height: 60, child: pw.Image(logo)),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              "HOJA DE CONTROL DIARIO",
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                codigo, // Ej: CC-HTC-05
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- 2. INFORMACIÓN GENERAL (Estilizada y Correcta) ---
  static pw.Widget _buildInfoSection(
    HojaTiempoSemana semana,
    HojaTiempoDiaria dia,
    String usuario,
    String fecha,
    PdfColor color,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.white,
      ),
      child: pw.Column(
        children: [
          _buildDataRow(
            "Cliente",
            semana.nombreCliente ?? 'No asignado',
            "Servicio",
            semana.nombreServicio ?? 'N/A',
          ),
          pw.Divider(color: PdfColors.grey200),
          // CORRECCIÓN AQUÍ: Mostramos "Centro de Costo" con el valor 'semana.centroCosto'
          _buildDataRow(
            "Orden Compra (OC)",
            semana.ocCliente?['cod_oc_cliente'] ?? 'S/I',
            "Centro de Costo",
            semana.centroCosto ?? 'S/I',
          ),
          pw.Divider(color: PdfColors.grey200),
          _buildDataRow(
            "Usuario",
            usuario,
            "Semana N°",
            "${semana.numeroSemana}",
          ),
          pw.Divider(color: PdfColors.grey200),
          // Fila fusionada (Fecha + Tipo + Viaje) para evitar cuadros vacíos
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSingleField("Fecha", fecha),
              _buildSingleField("Tipo Día", dia.tipoDia.replaceAll('_', ' ')),
              _buildSingleField("Viaje", "${dia.viajeHoras} hrs"),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDataRow(
    String label1,
    String val1,
    String label2,
    String val2,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(child: _buildSingleField(label1, val1)),
        pw.Expanded(child: _buildSingleField(label2, val2)),
      ],
    );
  }

  static pw.Widget _buildSingleField(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  // --- 3. TABLA DE ACTIVIDADES (Estilo Naranjo) ---
  static pw.Widget _buildActivitiesTable(
    List<HojaTiempoActividad> actividades,
    PdfColor baseColor,
  ) {
    if (actividades.isEmpty) {
      return pw.Container(
        height: 50,
        alignment: pw.Alignment.center,
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(
          "Sin actividades registradas",
          style: const pw.TextStyle(color: PdfColors.grey),
        ),
      );
    }

    final headers = ['Inicio', 'Término', 'Descripción de la Actividad'];
    final data = actividades
        .map((act) => [act.horaInicio, act.horaFin, act.descripcion])
        .toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 11,
      ),
      headerDecoration: pw.BoxDecoration(
        color: baseColor,
        borderRadius: const pw.BorderRadius.vertical(
          top: pw.Radius.circular(4),
        ),
      ),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
      ),
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.center,
        2: pw.Alignment.centerLeft,
      },
    );
  }

  // --- 4. RESUMEN HORIZONTAL (Estilo Full Width) ---
  static pw.Widget _buildResumenTableHorizontal(
    double habiles,
    double noHabiles,
    double festivas,
    double total,
    PdfColor baseColor,
  ) {
    final headers = [
      'Horas Hábiles',
      'Horas No Hábiles',
      'Horas Festivas',
      'TOTAL',
    ];
    final data = [
      [
        "${habiles.toStringAsFixed(2)} hrs",
        "${noHabiles.toStringAsFixed(2)} hrs",
        "${festivas.toStringAsFixed(2)} hrs",
        "${total.toStringAsFixed(2)} hrs",
      ],
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          "Resumen del Día",
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 5),

        pw.TableHelper.fromTextArray(
          headers: headers,
          data: data,
          border: null,
          headerDecoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: const pw.BorderRadius.vertical(
              top: pw.Radius.circular(4),
            ),
          ),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
            fontSize: 10,
          ),
          cellStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
          cellDecoration: (index, data, rowNum) {
            // CORRECCIÓN: Usamos PdfColors.orange50 que sí existe y es seguro
            if (index == 3) {
              return const pw.BoxDecoration(color: PdfColors.orange50);
            }
            return const pw.BoxDecoration(color: PdfColors.white);
          },
          cellAlignments: {
            0: pw.Alignment.center,
            1: pw.Alignment.center,
            2: pw.Alignment.center,
            3: pw.Alignment.center,
          },
          rowDecoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
              left: pw.BorderSide(color: PdfColors.grey300, width: 1),
              right: pw.BorderSide(color: PdfColors.grey300, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  // --- 5. PIE DE PÁGINA ---
  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              "Somnolence App - Reporte Oficial",
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
            ),
            pw.Text(
              "Generado el: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}",
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
