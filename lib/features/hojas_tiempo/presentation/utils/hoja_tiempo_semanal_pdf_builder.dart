import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../data/models/hoja_tiempo_model.dart';

class HojaTiempoSemanalPdfBuilder {
  static Future<Uint8List> buildPdfSemanal({
    required HojaTiempoSemana semana,
    required String nombreUsuario,
  }) async {
    final pdf = pw.Document();

    // 1. Cargar Recursos
    final imageBytes = await rootBundle.load('assets/images/LOGO.png');
    final logoImage = pw.MemoryImage(imageBytes.buffer.asUint8List());

    // Naranjo Corporativo
    final PdfColor baseColor = PdfColor.fromInt(0xFFEF6C00);

    // Formateo de fechas
    String _fmt(String f) {
      try {
        final partes = f.split('-');
        return "${partes[2]}-${partes[1]}-${partes[0]}";
      } catch (_) {
        return f;
      }
    }

    final periodo = "${_fmt(semana.fechaInicio)} al ${_fmt(semana.fechaFin)}";

    // Ordenar días cronológicamente
    final diasOrdenados = List<HojaTiempoDiaria>.from(semana.dias ?? []);
    diasOrdenados.sort((a, b) => a.fecha.compareTo(b.fecha));

    pdf.addPage(
      pw.MultiPage(
        // CAMBIO: Usamos Portrait (Vertical) para un look más formal
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => [
          // 1. Encabezado
          _buildHeader(
            semana.nombreComprobante ?? 'BORRADOR',
            logoImage,
            baseColor,
          ),
          pw.SizedBox(height: 20),

          // 2. Información General
          _buildInfoSection(semana, nombreUsuario, periodo),
          pw.SizedBox(height: 25),

          // 3. TABLA 1: Resumen Numérico (Limpia, sin texto largo)
          pw.Text(
            "1. Resumen de Horas",
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: baseColor,
            ),
          ),
          pw.SizedBox(height: 5),
          _buildNumericSummaryTable(diasOrdenados, baseColor),
          pw.SizedBox(height: 25),

          // 4. TABLA 2: Detalle de Actividades (Aquí va el texto)
          pw.Text(
            "2. Detalle de Actividades",
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: baseColor,
            ),
          ),
          pw.SizedBox(height: 5),
          _buildActivitiesDetailTable(diasOrdenados, baseColor),
          pw.SizedBox(height: 15),

          // 5. Observaciones
          if (semana.observacion != null && semana.observacion!.isNotEmpty)
            _buildObservacionBox(semana.observacion!, baseColor),

          pw.SizedBox(height: 30),

          // 6. Firmas (Usamos un Widget que intenta no romperse entre páginas)
          pw.Wrap(children: [_buildSignaturesSection()]),

          pw.SizedBox(height: 10),
          _buildFooter(),
        ],
      ),
    );

    return pdf.save();
  }

  // --- 1. ENCABEZADO ---
  static pw.Widget _buildHeader(
    String codigo,
    pw.MemoryImage logo,
    PdfColor color,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Container(height: 55, child: pw.Image(logo)),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              "REPORTE SEMANAL DE HORAS",
              style: pw.TextStyle(
                fontSize: 14,
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
                codigo,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- 2. INFO GENERAL ---
  static pw.Widget _buildInfoSection(
    HojaTiempoSemana semana,
    String usuario,
    String periodo,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
        color: PdfColors.white,
      ),
      child: pw.Column(
        children: [
          _buildDataRow(
            "Cliente",
            semana.nombreCliente ?? 'N/A',
            "Servicio",
            semana.nombreServicio ?? 'N/A',
          ),
          pw.Divider(color: PdfColors.grey200, thickness: 0.5),
          _buildDataRow(
            "Orden Compra (OC)",
            semana.ocCliente?['cod_oc_cliente'] ?? 'S/I',
            "Centro de Costo",
            semana.centroCosto ?? 'S/I',
          ),
          pw.Divider(color: PdfColors.grey200, thickness: 0.5),
          _buildDataRow("Usuario", usuario, "Periodo", periodo),
        ],
      ),
    );
  }

  // --- 3. TABLA NUMÉRICA (RESUMEN) ---
  static pw.Widget _buildNumericSummaryTable(
    List<HojaTiempoDiaria> dias,
    PdfColor baseColor,
  ) {
    final headers = [
      'Día',
      'Fecha',
      'Hábiles',
      'No Hábiles',
      'Festivos',
      'Viaje',
      'TOTAL\n(s/ Viaje)',
    ];

    double tHab = 0, tNoHab = 0, tFest = 0, tViaje = 0, tGlobal = 0;
    const diasSemana = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"];

    final data = dias.map((dia) {
      double hHab = 0, hNoHab = 0, hFest = 0;
      if (dia.actividades != null) {
        for (var act in dia.actividades!) {
          hHab += act.horasHabiles;
          hNoHab += act.horasNoHabiles;
          hFest += act.horasFestivas;
        }
      }
      double totalDia = hHab + hNoHab + hFest;
      double viaje = dia.viajeHoras.toDouble();

      tHab += hHab;
      tNoHab += hNoHab;
      tFest += hFest;
      tViaje += viaje;
      tGlobal += totalDia;

      return [
        diasSemana[dia.fecha.weekday - 1],
        DateFormat('dd-MM').format(dia.fecha),
        hHab > 0 ? hHab.toStringAsFixed(1) : "-",
        hNoHab > 0 ? hNoHab.toStringAsFixed(1) : "-",
        hFest > 0 ? hFest.toStringAsFixed(1) : "-",
        viaje > 0 ? viaje.toStringAsFixed(1) : "-",
        totalDia > 0 ? totalDia.toStringAsFixed(1) : "-",
      ];
    }).toList();

    // Fila Totales
    data.add([
      "",
      "TOTALES",
      tHab.toStringAsFixed(1),
      tNoHab.toStringAsFixed(1),
      tFest.toStringAsFixed(1),
      tViaje.toStringAsFixed(1),
      tGlobal.toStringAsFixed(1),
    ]);

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 9,
      ),
      headerDecoration: pw.BoxDecoration(
        color: baseColor,
        borderRadius: const pw.BorderRadius.vertical(
          top: pw.Radius.circular(4),
        ),
      ),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
        5: pw.Alignment.center,
        6: pw.Alignment.center,
      },
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
      ),
      cellDecoration: (index, data, rowNum) {
        if (rowNum == dias.length)
          return const pw.BoxDecoration(
            color: PdfColors.orange50,
          ); // Fila Totales
        if (index == 6)
          return pw.BoxDecoration(
            color: PdfColors.grey100,
          ); // Columna Total sombreada
        return const pw.BoxDecoration();
      },
    );
  }

  // --- 4. TABLA DETALLE ACTIVIDADES (TEXTO) ---
  // --- 4. TABLA DETALLE ACTIVIDADES (TEXTO) ---
  static pw.Widget _buildActivitiesDetailTable(
    List<HojaTiempoDiaria> dias,
    PdfColor baseColor,
  ) {
    // 1. Añadimos la columna "Ubicación"
    final headers = [
      'Día',
      'Ubicación',
      'Horario',
      'Descripción de la Actividad',
    ];
    final List<List<String>> data = [];
    const diasSemana = [
      "Lunes",
      "Martes",
      "Miércoles",
      "Jueves",
      "Viernes",
      "Sábado",
      "Domingo",
    ];

    for (var dia in dias) {
      if (dia.actividades != null && dia.actividades!.isNotEmpty) {
        int index = 1;

        // Formateamos la ubicación para que se vea limpia
        String areaStr = (dia.area != null && dia.area!.isNotEmpty)
            ? dia.area!
            : 'N/A';
        String ubicacion = "${dia.lugar}\n($areaStr)";

        for (var act in dia.actividades!) {
          data.add([
            // Solo mostramos el día y la ubicación en la primera actividad de ese día para no repetir visualmente
            index == 1
                ? "${diasSemana[dia.fecha.weekday - 1]}\n${DateFormat('dd/MM').format(dia.fecha)}"
                : "",
            index == 1 ? ubicacion : "",
            "${act.horaInicio} -\n${act.horaFin}", // Salto de línea en la hora para ahorrar espacio
            "${index++}. ${act.descripcion}",
          ]);
        }
      }
    }

    if (data.isEmpty) {
      return pw.Text(
        "Sin actividades detalladas.",
        style: const pw.TextStyle(color: PdfColors.grey),
      );
    }

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 9,
      ),
      headerDecoration: pw.BoxDecoration(
        color: baseColor,
        borderRadius: const pw.BorderRadius.vertical(
          top: pw.Radius.circular(4),
        ),
      ),
      cellStyle: const pw.TextStyle(fontSize: 9),
      columnWidths: {
        0: const pw.FixedColumnWidth(50), // Día
        1: const pw.FixedColumnWidth(80), // Ubicación (Lugar + Área)
        2: const pw.FixedColumnWidth(60), // Horario
        3: const pw.FlexColumnWidth(), // Descripción (ocupa todo el resto)
      },
      cellAlignments: {
        0: pw
            .Alignment
            .topCenter, // Alineados arriba para que no floten si la descripción es larga
        1: pw.Alignment.topCenter,
        2: pw.Alignment.topCenter,
        3: pw.Alignment.topLeft,
      },
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300),
        ), // Borde gris claro para separar
      ),
    );
  }

  // --- COMPONENTES AUXILIARES ---
  static pw.Widget _buildObservacionBox(String obs, PdfColor color) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(5),
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "OBSERVACIONES ADICIONALES:",
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
              color: color,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(obs, style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  static pw.Widget _buildSignaturesSection() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        _buildSignatureLine("Firma Responsable Cliente"),
        _buildSignatureLine("Firma Emisor (Trabajador)"),
      ],
    );
  }

  static pw.Widget _buildSignatureLine(String label) {
    return pw.Column(
      children: [
        pw.Container(
          width: 180,
          height: 40,
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black)),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          label,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        ),
      ],
    );
  }

  static pw.Widget _buildDataRow(String l1, String v1, String l2, String v2) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Expanded(child: _buildSingleField(l1, v1)),
          pw.Expanded(child: _buildSingleField(l2, v2)),
        ],
      ),
    );
  }

  static pw.Widget _buildSingleField(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 80,
          child: pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              "Somnolence App - Gestión de Tiempos",
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
            ),
            pw.Text(
              "Generado el: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}",
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
