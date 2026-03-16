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

    final imageBytes = await rootBundle.load('assets/images/LOGO.png');
    final logoImage = pw.MemoryImage(imageBytes.buffer.asUint8List());

    final PdfColor baseColor = PdfColor.fromInt(0xFFEF6C00);

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

    // --- NUEVO: OBTENER EL NOMBRE DEL VALIDADOR ---
    // Si el día tiene su propio validador, lo usamos. Si no, heredamos el de la semana.
    String nombreValidadorFinal =
        dia.validadorNombre ?? semana.validadorNombre ?? '';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => [
          _buildHeader(logoImage, baseColor),
          pw.SizedBox(height: 25),
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
          _buildFooter(nombreValidadorFinal), // <-- Inyectamos el nombre al pie
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(pw.MemoryImage logo, PdfColor color) {
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
          ],
        ),
      ],
    );
  }

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
          _buildDataRow(
            "Orden Compra (OC)",
            semana.ocCliente?['cod_oc_cliente'] ?? 'S/I',
            "Centro de Costo",
            semana.centroCosto ?? 'S/I',
          ),
          pw.Divider(color: PdfColors.grey200),
          _buildDataRow(
            "Nombre",
            usuario,
            "Semana N°",
            "${semana.numeroSemana}",
          ),
          pw.Divider(color: PdfColors.grey200),
          _buildDataRow(
            "Lugar",
            dia.lugar,
            "Área",
            dia.area ?? 'No especificada',
          ),
          pw.Divider(color: PdfColors.grey200),
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

  // --- REEMPLAZO EXACTO QUE PEDISTE ---
  static pw.Widget _buildFooter(String validador) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              validador.isNotEmpty
                  ? "Validado por: $validador"
                  : "Validado por: ___________________________",
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
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
