import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:somnolence_app/features/hojas_tiempo/presentation/screens/hoja_detail_screen.dart';
import '../providers/hoja_tiempo_provider.dart';
import '../widgets/modal_crear_semana.dart';

class HojasListScreen extends StatefulWidget {
  const HojasListScreen({super.key});

  @override
  State<HojasListScreen> createState() => _HojasListScreenState();
}

class _HojasListScreenState extends State<HojasListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<HojaTiempoProvider>().cargarHojas(user.id);
      }
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
      appBar: AppBar(
        title: const Text(
          "Mis Hojas de Tiempo",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const ModalCrearSemana(),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Nueva Semana",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Consumer<HojaTiempoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.hojas.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.hojas.isEmpty) {
            return Center(child: Text(provider.errorMessage!));
          }

          if (provider.hojas.isEmpty) {
            return const Center(
              child: Text("No tienes hojas de tiempo registradas."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.hojas.length,
            itemBuilder: (context, index) {
              final hoja = provider.hojas[index];
              final nombreServicio =
                  hoja.servicio?['nombre_servicio'] ?? 'Servicio Desconocido';

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
                      fontSize: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        "Cliente: ${hoja.nombreCliente}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "$nombreServicio",
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Periodo: ${_formatFecha(hoja.fechaInicio)} al ${_formatFecha(hoja.fechaFin)}",
                        style: TextStyle(
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
                      color: hoja.estado == 'Borrador'
                          ? Colors.orange.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      hoja.estado,
                      style: TextStyle(
                        color: hoja.estado == 'Borrador'
                            ? Colors.orange[800]
                            : Colors.green[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () {
                    if (hoja.idHojaSemana != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HojaDetailScreen(
                            idHojaSemana: hoja.idHojaSemana!,
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
