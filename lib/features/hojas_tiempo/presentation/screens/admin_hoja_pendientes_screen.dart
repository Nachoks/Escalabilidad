import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/hojas_tiempo/presentation/screens/admin_hoja_evaluacion_screen.dart';
import '../providers/hoja_tiempo_provider.dart';
import '../../data/models/hoja_tiempo_model.dart';

class AdminHojasPendientesScreen extends StatefulWidget {
  const AdminHojasPendientesScreen({Key? key}) : super(key: key);

  @override
  State<AdminHojasPendientesScreen> createState() =>
      _AdminHojasPendientesScreenState();
}

class _AdminHojasPendientesScreenState
    extends State<AdminHojasPendientesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatos();
    });
  }

  Future<void> _cargarDatos() async {
    final provider = context.read<HojaTiempoProvider>();
    await Future.wait([
      provider.cargarPendientesAdmin(),
      provider.cargarPendientesDiariasAdmin(),
    ]);
  }

  String _formatFecha(String fecha) {
    final partes = fecha.split('-');
    if (partes.length == 3) {
      return "${partes[2]}-${partes[1]}-${partes[0]}";
    }
    return fecha;
  }

  // --- DIÁLOGO PARA EVALUAR UN DÍA INDIVIDUAL (CON DETALLE DE ACTIVIDADES) ---
  void _mostrarDialogoEvaluarDia(BuildContext context, HojaTiempoDiaria dia) {
    final TextEditingController obsController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.assignment_turned_in,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Evaluar Día: ${_formatFecha(dia.fecha.toString().split(' ')[0])}",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Usuario: ${dia.nombrePersonal ?? 'S/I'}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text("Cliente: ${dia.nombreCliente ?? 'S/I'}"),
                      // 👇 NUEVOS DATOS MOSTRADOS EN EL POP-UP 👇
                      Text("Servicio: ${dia.nombreServicio ?? 'S/I'}"),
                      Text(
                        "Centro de Costo: ${dia.centroCosto ?? 'S/I'}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.blueGrey,
                        ),
                      ),
                      Text("Horas de Viaje: ${dia.viajeHoras} hrs"),
                      Text("Lugar: ${dia.lugar} • Tipo: ${dia.tipoDia}"),
                      const SizedBox(height: 16),

                      // --- DETALLE DE ACTIVIDADES ---
                      const Text(
                        "Actividades Registradas:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (dia.actividades == null || dia.actividades!.isEmpty)
                        const Text(
                          "No se registraron actividades en este día.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade50,
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: dia.actividades!.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final act = dia.actividades![index];
                              final totalHoras =
                                  act.horasHabiles +
                                  act.horasNoHabiles +
                                  act.horasFestivas;

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                visualDensity: VisualDensity.compact,
                                title: Text(
                                  act.descripcion,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 12,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${act.horaInicio} - ${act.horaFin}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "(${totalHoras.toStringAsFixed(1)} hrs)",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 20),
                      TextField(
                        controller: obsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText:
                              "Observaciones (Obligatorio si se rechaza)",
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (obsController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Debes ingresar un motivo de rechazo",
                                ),
                              ),
                            );
                            return;
                          }
                          setModalState(() => isSubmitting = true);
                          final provider = context.read<HojaTiempoProvider>();
                          final exito = await provider.evaluarDiaAdmin(
                            idHojaDiaria: dia.idHojaDiaria,
                            estado: 'Rechazada',
                            observacion: obsController.text.trim(),
                          );
                          if (!context.mounted) return;
                          setModalState(() => isSubmitting = false);
                          if (exito) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Día Rechazado"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Rechazar",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setModalState(() => isSubmitting = true);
                          final provider = context.read<HojaTiempoProvider>();
                          final exito = await provider.evaluarDiaAdmin(
                            idHojaDiaria: dia.idHojaDiaria,
                            estado: 'Aprobada',
                            observacion: obsController.text.trim(),
                          );
                          if (!context.mounted) return;
                          setModalState(() => isSubmitting = false);
                          if (exito) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Día Aprobado"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Aprobar",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 850;

          return Scaffold(
            backgroundColor: isDesktop
                ? const Color(0xFFF4F6F8)
                : Colors.grey.shade50,

            // --- APPBAR CON PESTAÑAS ---
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              elevation: 2,
              toolbarHeight: 70,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Row(
                children: [
                  const Image(
                    image: AssetImage('assets/images/isotipo.png'),
                    width: 45,
                    height: 45,
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Validación Pendiente',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Recargar',
                  onPressed: _cargarDatos,
                ),
                const SizedBox(width: 16),
              ],
              bottom: const TabBar(
                indicatorColor: Colors.white,
                indicatorWeight: 4,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                tabs: [
                  Tab(
                    text: "Semanas Completas",
                    icon: Icon(Icons.calendar_month),
                  ),
                  Tab(text: "Días Individuales", icon: Icon(Icons.today)),
                ],
              ),
            ),

            // --- CUERPO ---
            body: Consumer<HojaTiempoProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final semanasPendientes = provider.adminPendientes;
                final diasPendientes = provider.adminPendientesDiarias;

                return TabBarView(
                  children: [
                    // PESTAÑA 1: SEMANAS
                    RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _cargarDatos,
                      child: semanasPendientes.isEmpty
                          ? _buildEmptyState(
                              "¡Todo al día!",
                              "No hay semanas completas pendientes por revisar.",
                            )
                          : Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: isDesktop ? 1200 : double.infinity,
                                ),
                                child: isDesktop
                                    ? GridView.builder(
                                        padding: const EdgeInsets.all(32),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              childAspectRatio: 2.5,
                                              crossAxisSpacing: 24,
                                              mainAxisSpacing: 24,
                                            ),
                                        itemCount: semanasPendientes.length,
                                        itemBuilder: (context, index) =>
                                            _buildHojaSemanaCard(
                                              semanasPendientes[index],
                                              isDesktop: true,
                                            ),
                                      )
                                    : ListView.separated(
                                        padding: const EdgeInsets.all(16),
                                        itemCount: semanasPendientes.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 12),
                                        itemBuilder: (context, index) =>
                                            _buildHojaSemanaCard(
                                              semanasPendientes[index],
                                              isDesktop: false,
                                            ),
                                      ),
                              ),
                            ),
                    ),

                    // PESTAÑA 2: DÍAS INDIVIDUALES
                    RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _cargarDatos,
                      child: diasPendientes.isEmpty
                          ? _buildEmptyState(
                              "¡Excelente!",
                              "No hay días individuales pendientes por revisar.",
                            )
                          : Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: isDesktop ? 1200 : double.infinity,
                                ),
                                child: isDesktop
                                    ? GridView.builder(
                                        padding: const EdgeInsets.all(32),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              childAspectRatio: 2.5,
                                              crossAxisSpacing: 24,
                                              mainAxisSpacing: 24,
                                            ),
                                        itemCount: diasPendientes.length,
                                        itemBuilder: (context, index) =>
                                            _buildHojaDiaCard(
                                              diasPendientes[index],
                                              isDesktop: true,
                                            ),
                                      )
                                    : ListView.separated(
                                        padding: const EdgeInsets.all(16),
                                        itemCount: diasPendientes.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 12),
                                        itemBuilder: (context, index) =>
                                            _buildHojaDiaCard(
                                              diasPendientes[index],
                                              isDesktop: false,
                                            ),
                                      ),
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  // --- TARJETA PARA SEMANAS ---
  Widget _buildHojaSemanaCard(
    HojaTiempoSemana hoja, {
    required bool isDesktop,
  }) {
    final nombreServicio = hoja.nombreServicio ?? 'Servicio Desconocido';
    final nombreCliente = hoja.nombreCliente ?? 'Cliente Desconocido';
    final titulo = hoja.nombreComprobante ?? "Semana ${hoja.numeroSemana}";
    final personal = hoja.nombrePersonal ?? "S/I";

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
            _cargarDatos();
          }
        },
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                      "SEMANA PENDIENTE",
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
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
                          personal,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "$nombreCliente - $nombreServicio",
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
              if (isDesktop) const Spacer(),
              if (!isDesktop) const SizedBox(height: 12),
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
                        "${_formatFecha(hoja.fechaInicio)} al ${_formatFecha(hoja.fechaFin)}",
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
                        "Ver Detalle",
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

  // --- TARJETA PARA DÍAS INDIVIDUALES ---
  Widget _buildHojaDiaCard(HojaTiempoDiaria dia, {required bool isDesktop}) {
    final personal = dia.nombrePersonal ?? "Usuario S/I";
    final cliente = dia.nombreCliente ?? "Cliente S/I";
    final servicio = dia.nombreServicio ?? "Servicio S/I"; // 👇 NUEVO
    final fechaDia = _formatFecha(dia.fecha.toString().split(' ')[0]);

    return Card(
      elevation: isDesktop ? 0 : 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDesktop
            ? BorderSide(color: Colors.grey.shade300)
            : BorderSide.none,
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Día: $fechaDia",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isDesktop ? 18 : 16,
                      color: Colors.blue.shade800,
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
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.shade300),
                  ),
                  child: Text(
                    "DÍA PENDIENTE",
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_pin,
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
                        personal,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // 👇 ACTUALIZADO PARA MOSTRAR CLIENTE Y SERVICIO 👇
                      Text(
                        "$cliente - $servicio",
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
            if (isDesktop) const Spacer(),
            if (!isDesktop) const SizedBox(height: 12),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.work_history,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${dia.actividades?.length ?? 0} actividades",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _mostrarDialogoEvaluarDia(context, dia),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Evaluar", style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String titulo, String subtitulo) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitulo,
            style: TextStyle(fontSize: 15, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
