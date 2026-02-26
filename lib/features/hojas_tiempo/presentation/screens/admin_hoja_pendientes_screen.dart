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
    final partes = fecha.split('-');
    if (partes.length == 3) {
      return "${partes[2]}-${partes[1]}-${partes[0]}";
    }
    return fecha;
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
                        'Hojas por Evaluar',
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
                      tooltip: 'Recargar',
                      onPressed: () {
                        _cargarPendientes();
                      },
                    ),
                    const SizedBox(width: 16),
                  ],
                )
              : AppBar(
                  title: const Text(
                    'Hojas por Evaluar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: AppColors.primary,
                  iconTheme: const IconThemeData(color: Colors.white),
                  elevation: 0,
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

          // --- CUERPO ---
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
                  return _buildEmptyState();
                }

                final pendientes = snapshot.data!;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 1200 : double.infinity,
                    ), // Centrado en PC
                    child: isDesktop
                        // =====================================
                        // 💻 VISTA ESCRITORIO (GRILLA)
                        // =====================================
                        ? GridView.builder(
                            padding: const EdgeInsets.all(32),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // 2 columnas
                                  childAspectRatio:
                                      2.5, // Tarjetas rectangulares tipo "ticket"
                                  crossAxisSpacing: 24,
                                  mainAxisSpacing: 24,
                                ),
                            itemCount: pendientes.length,
                            itemBuilder: (context, index) => _buildHojaCard(
                              pendientes[index],
                              isDesktop: true,
                            ),
                          )
                        // =====================================
                        // 📱 VISTA MÓVIL (LISTA VERTICAL)
                        // =====================================
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: pendientes.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) => _buildHojaCard(
                              pendientes[index],
                              isDesktop: false,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // --- TARJETA DE HOJA ADAPTATIVA ---
  Widget _buildHojaCard(HojaTiempoSemana hoja, {required bool isDesktop}) {
    final nombreServicio = hoja.nombreServicio ?? 'Servicio Desconocido';
    final nombreCliente = hoja.nombreCliente ?? 'Cliente Desconocido';
    final titulo = hoja.nombreComprobante ?? "Semana ${hoja.numeroSemana}";

    return Card(
      elevation: isDesktop ? 0 : 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDesktop
            ? BorderSide(color: Colors.grey.shade300)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AdminHojaEvaluacionScreen(idHojaSemana: hoja.idHojaSemana!),
            ),
          );
          if (resultado == true) {
            _cargarPendientes();
          }
        },
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cabecera: Título y Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      titulo,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isDesktop ? 20 : 18,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Text(
                      "POR EVALUAR",
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Cuerpo: Cliente y Servicio
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.business,
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
                          nombreCliente,
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
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
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
                const Spacer(), // Empuja las fechas hacia abajo en PC
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
          Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            '¡Todo al día!',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No hay hojas de tiempo pendientes por revisar.',
            style: TextStyle(fontSize: 15, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
