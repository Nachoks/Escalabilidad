import 'package:flutter/material.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/hojas_tiempo/presentation/screens/admin_hoja_evaluacion_screen.dart';
import '../../data/models/hoja_tiempo_model.dart';
import '../../data/services/hoja_tiempo_service.dart';

class AdminHojasPendientesScreen extends StatefulWidget {
  const AdminHojasPendientesScreen({Key? key}) : super(key: key);

  @override
  State<AdminHojasPendientesScreen> createState() =>
      _AdminHojasPendientesScreenState();
}

class _AdminHojasPendientesScreenState
    extends State<AdminHojasPendientesScreen> {
  final HojaTiempoService _hojaService = HojaTiempoService();
  late Future<List<HojaTiempoSemana>> _futurePendientes;

  @override
  void initState() {
    super.initState();
    _cargarPendientes();
  }

  void _cargarPendientes() {
    setState(() {
      _futurePendientes = _hojaService.obtenerPendientesAdmin();
    });
  }

  String _formatFecha(String fecha) {
    // Convierte 2026-02-16 a 16-02-2026
    final partes = fecha.split('-');
    if (partes.length == 3) {
      return "${partes[2]}-${partes[1]}-${partes[0]}";
    }
    return fecha;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // Fondo suave
      appBar: AppBar(
        title: const Text(
          'Hojas por Evaluar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          _cargarPendientes();
          await _futurePendientes;
        },
        child: FutureBuilder<List<HojaTiempoSemana>>(
          future: _futurePendientes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No hay hojas de tiempo pendientes por revisar.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            final pendientes = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendientes.length,
              itemBuilder: (context, index) {
                final hoja = pendientes[index];
                final nombreServicio =
                    hoja.nombreServicio ?? 'Servicio Desconocido';
                final nombreCliente =
                    hoja.nombreCliente ?? 'Cliente Desconocido';

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      hoja.nombreComprobante ?? "Semana ${hoja.numeroSemana}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          "Cliente: $nombreCliente",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          nombreServicio,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Periodo: ${_formatFecha(hoja.fechaInicio)} al ${_formatFecha(hoja.fechaFin)}",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Semana: ${hoja.numeroSemana}",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "POR EVALUAR",
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    onTap: () async {
                      final resultado = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminHojaEvaluacionScreen(
                            idHojaSemana: hoja.idHojaSemana!,
                          ),
                        ),
                      );

                      // Si evaluó la hoja y volvió, recargamos la lista
                      if (resultado == true) {
                        _cargarPendientes();
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
