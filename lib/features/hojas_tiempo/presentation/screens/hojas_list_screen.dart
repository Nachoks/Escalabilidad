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
    final partes = fecha.split('-');
    if (partes.length == 3) {
      return "${partes[2]}-${partes[1]}-${partes[0]}";
    }
    return fecha;
  }

  void _abrirModalCrear(BuildContext context, bool isDesktop) {
    if (isDesktop) {
      showDialog(
        context: context,
        builder: (_) => const Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: SizedBox(
            width: 500, // Ancho controlado para el modal en PC
            child: ModalCrearSemana(),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const ModalCrearSemana(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        return Scaffold(
          backgroundColor: isDesktop
              ? const Color(0xFFF4F6F8)
              : Colors.grey.shade50,

          // --- APPBAR ADAPTATIVO ---
          appBar: isDesktop
              ? AppBar(
                  backgroundColor: AppColors.primary,
                  elevation: 2,
                  toolbarHeight: 70,
                  title: Row(
                    children: [
                      const Image(
                        image: AssetImage('assets/images/isotipo.png'),
                        width: 45,
                        height: 45,
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        "Mis Hojas de Tiempo",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  iconTheme: const IconThemeData(color: Colors.white),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: "Recargar",
                      onPressed: () {
                        final user = context.read<AuthProvider>().currentUser;
                        if (user != null) {
                          context.read<HojaTiempoProvider>().cargarHojas(
                            user.id,
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                  ],
                )
              : AppBar(
                  title: const Text(
                    "Mis Hojas de Tiempo",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: AppColors.primary,
                  iconTheme: const IconThemeData(color: Colors.white),
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                      ),
                    ),
                  ),
                ),

          // --- BOTÓN FLOTANTE ---
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            onPressed: () => _abrirModalCrear(context, isDesktop),
            icon: const Icon(Icons.add),
            label: isDesktop
                ? const Text(
                    "NUEVA SEMANA",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                : const Text("Nueva Semana"),
          ),

          // --- CUERPO ---
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop
                    ? 1200
                    : double.infinity, // Ancho suficiente para 2 columnas
              ),
              child: Consumer<HojaTiempoProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.hojas.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.errorMessage != null && provider.hojas.isEmpty) {
                    return Center(child: Text(provider.errorMessage!));
                  }

                  if (provider.hojas.isEmpty) {
                    return _buildEmptyState();
                  }

                  return isDesktop
                      // =====================================
                      // 💻 VISTA ESCRITORIO (GRILLA)
                      // =====================================
                      ? GridView.builder(
                          padding: const EdgeInsets.all(32),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // 2 columnas
                                childAspectRatio:
                                    2.2, // Proporción tipo "Ticket"
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 24,
                              ),
                          itemCount: provider.hojas.length,
                          itemBuilder: (context, index) => _buildHojaCard(
                            provider.hojas[index],
                            isDesktop: true,
                          ),
                        )
                      // =====================================
                      // 📱 VISTA MÓVIL (LISTA VERTICAL)
                      // =====================================
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.hojas.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) => _buildHojaCard(
                            provider.hojas[index],
                            isDesktop: false,
                          ),
                        );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET TARJETA DE HOJA ADAPTATIVA ---
  Widget _buildHojaCard(dynamic hoja, {required bool isDesktop}) {
    final nombreServicio =
        hoja.servicio?['nombre_servicio'] ?? 'Servicio Desconocido';

    // Lógica de colores de estado
    Color colorFondo;
    Color colorTexto;
    switch (hoja.estado.toLowerCase()) {
      case 'aprobada':
        colorFondo = Colors.green.shade50;
        colorTexto = Colors.green[800]!;
        break;
      case 'rechazada':
        colorFondo = Colors.red.shade50;
        colorTexto = Colors.red[800]!;
        break;
      case 'enviada':
        colorFondo = Colors.blue.shade50;
        colorTexto = Colors.blue[800]!;
        break;
      default: // Borrador
        colorFondo = Colors.orange.shade50;
        colorTexto = Colors.orange[800]!;
    }

    return Card(
      elevation: isDesktop ? 0 : 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDesktop
            ? BorderSide(color: Colors.grey.shade300)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (hoja.idHojaSemana != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    HojaDetailScreen(idHojaSemana: hoja.idHojaSemana!),
              ),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 24 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cabecera: Título y Estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      hoja.nombreComprobante ?? "Semana ${hoja.numeroSemana}",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: isDesktop ? 20 : 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorFondo,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorTexto.withOpacity(0.3)),
                    ),
                    child: Text(
                      hoja.estado.toUpperCase(),
                      style: TextStyle(
                        color: colorTexto,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Cuerpo: Detalles
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.business_center_outlined,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hoja.nombreCliente ?? "Sin Cliente",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          nombreServicio,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (isDesktop)
                const Spacer(), // Empuja las fechas hacia el fondo en PC
              if (!isDesktop) const SizedBox(height: 12),

              // Pie: Fechas y Semana
              Divider(color: Colors.grey.shade200),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${_formatFecha(hoja.fechaInicio)}  al  ${_formatFecha(hoja.fechaFin)}",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Semana ${hoja.numeroSemana}",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time_filled, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No tienes hojas de tiempo",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text("Crea una nueva semana para comenzar a registrar"),
        ],
      ),
    );
  }
}
