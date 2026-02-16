import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/hojas_tiempo/presentation/screens/hoja_dia_screen.dart';
import '../providers/hoja_tiempo_provider.dart';

class HojaDetailScreen extends StatefulWidget {
  final int idHojaSemana;

  const HojaDetailScreen({super.key, required this.idHojaSemana});

  @override
  State<HojaDetailScreen> createState() => _HojaDetailScreenState();
}

class _HojaDetailScreenState extends State<HojaDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Cargamos el detalle apenas se abre la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HojaTiempoProvider>().cargarDetalleHoja(widget.idHojaSemana);
    });
  }

  // Utilidad para obtener el nombre del día en español
  String _obtenerNombreDia(DateTime fecha) {
    const nombres = [
      "Lunes",
      "Martes",
      "Miércoles",
      "Jueves",
      "Viernes",
      "Sábado",
      "Domingo",
    ];
    return nombres[fecha.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detalle de la Semana",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<HojaTiempoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final hoja = provider.hojaSeleccionada;

          if (hoja == null) {
            return const Center(child: Text("No se encontró información."));
          }

          final dias = hoja.dias ?? [];

          return Column(
            children: [
              // --- CABECERA INFORMATIVA ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: AppColors.primary.withOpacity(0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hoja.nombreComprobante ?? "Sin Nombre",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "C. Costo: ${hoja.centroCosto ?? 'N/A'}",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "Estado: ${hoja.estado}",
                      style: TextStyle(
                        color: hoja.estado == 'Borrador'
                            ? Colors.orange
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              // --- LISTA DE LOS 7 DÍAS ---
              Expanded(
                child: dias.isEmpty
                    ? const Center(
                        child: Text("No hay días generados para esta semana."),
                      )
                    : ListView.builder(
                        itemCount: dias.length,
                        // AQUÍ CAMBIAMOS EL PADDING PARA DAR MÁS AIRE ABAJO (bottom: 24)
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 24,
                          left: 8,
                          right: 8,
                        ),
                        itemBuilder: (context, index) {
                          final dia = dias[index];
                          final nombreDia = _obtenerNombreDia(dia.fecha);
                          final cantidadActividades =
                              dia.actividades?.length ?? 0;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: dia.tipoDia == 'HABIL'
                                    ? AppColors.primary
                                    : Colors.grey,
                                child: Text(
                                  dia.fecha.day.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                nombreDia,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text("${dia.tipoDia} • ${dia.lugar}"),
                                  if (cantidadActividades > 0)
                                    Text(
                                      "$cantidadActividades actividad(es) registrada(s)",
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HojaDiaEditScreen(
                                      dia: dia,
                                    ), // <-- ¡AQUÍ ESTÁ EL ERROR!
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      // --- BOTÓN INFERIOR FIJO CON SAFEA REA ---
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          // Opcional: una ligera sombra arriba del botón para separarlo de la lista
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // TODO: Lógica para validar que todos los días estén completos y cambiar estado a "Enviada"
            },
            child: const Text(
              "ENVIAR A VALIDAR",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
