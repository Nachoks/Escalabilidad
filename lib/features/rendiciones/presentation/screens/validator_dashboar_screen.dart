import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/rendiciones/data/models/rendicion_model.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/rendiciones_provider.dart';
import 'package:somnolence_app/features/rendiciones/presentation/screens/rendicion_validacion_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class ValidatorDashboardScreen extends StatefulWidget {
  const ValidatorDashboardScreen({super.key});

  @override
  State<ValidatorDashboardScreen> createState() =>
      _ValidatorDashboardScreenState();
}

class _ValidatorDashboardScreenState extends State<ValidatorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RendicionesProvider>().cargarBandejaValidacion();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatMoney(int amount) {
    return "\$${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  // --- LÓGICA DE PAGO ---
  Future<void> _procesarPago(BuildContext context, int idRendicion) async {
    final picker = ImagePicker();
    String? pathSeleccionado;

    // 1. Preguntar origen
    final String? opcion = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "Adjuntar Comprobante de Transferencia",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text("Tomar Foto"),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text("Galería"),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text("Archivo PDF"),
              onTap: () => Navigator.pop(ctx, 'pdf'),
            ),
          ],
        ),
      ),
    );

    if (opcion == null) return;
    if (!mounted) return;

    // 2. Obtener archivo
    if (opcion == 'camera') {
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 60,
      );
      pathSeleccionado = photo?.path;
    } else if (opcion == 'gallery') {
      final XFile? photo = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
      );
      pathSeleccionado = photo?.path;
    } else {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      pathSeleccionado = result?.files.single.path;
    }

    if (pathSeleccionado == null) return;
    if (!mounted) return;

    // -----------------------------------------------------------
    // SOLUCIÓN AL ERROR DE CONTEXTO
    // -----------------------------------------------------------

    // 1. Capturamos las referencias AHORA que el contexto es seguro
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<RendicionesProvider>();

    // 2. Usamos 'messenger' (la variable) en vez de 'ScaffoldMessenger.of(context)'
    messenger.showSnackBar(
      const SnackBar(
        content: Text("Subiendo comprobante..."),
        duration: Duration(seconds: 1),
      ),
    );

    // 3. Hacemos la llamada asíncrona usando la referencia 'provider' capturada
    final exito = await provider.pagarRendicion(idRendicion, pathSeleccionado);

    // 4. Usamos 'messenger' de nuevo para mostrar el resultado.
    // Esto funciona aunque el widget se haya desmontado o el contexto haya cambiado.
    if (exito) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("¡Pago registrado correctamente!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Error al subir comprobante."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RendicionesProvider>();

    final listaPorRevisar = provider.rendicionesPorValidar
        .where((r) => r.estado == 'Pendiente de Validación')
        .toList();

    final listaPorPagar = provider.rendicionesPorValidar
        .where((r) => r.estado == 'Aprobada')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Gestión de Gastos",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: [
            Tab(
              text: "Por Revisar",
              icon: Badge(
                label: Text("${listaPorRevisar.length}"),
                isLabelVisible: listaPorRevisar.isNotEmpty,
                child: const Icon(Icons.fact_check_outlined),
              ),
            ),
            Tab(
              text: "Por Pagar",
              icon: Badge(
                label: Text("${listaPorPagar.length}"),
                isLabelVisible: listaPorPagar.isNotEmpty,
                backgroundColor: Colors.green,
                child: const Icon(Icons.attach_money),
              ),
            ),
          ],
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildListaRendiciones(listaPorRevisar, esParaPago: false),
                _buildListaRendiciones(listaPorPagar, esParaPago: true),
              ],
            ),
    );
  }

  Widget _buildListaRendiciones(
    List<RendicionModel> lista, {
    required bool esParaPago,
  }) {
    if (lista.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              esParaPago
                  ? Icons.payments_outlined
                  : Icons.assignment_turned_in_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              esParaPago
                  ? "No hay pagos pendientes"
                  : "¡Estás al día! Nada por revisar",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: lista.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = lista[index];
        final idVisual =
            "#${(item.idRendicion ?? 0).toString().padLeft(3, '0')}";

        final borderSideColor = esParaPago ? Colors.green : Colors.orange;

        // Cálculos Financieros
        final int asignado = item.montoEntregado;
        final int gastado = item.totalGastado;
        final int saldo = asignado - gastado;
        final bool esReembolso = saldo < 0;

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderSideColor.withOpacity(0.5), width: 1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (esParaPago) {
                // Si es para pagar, abrimos el menú de carga
                _procesarPago(context, item.idRendicion!);
              } else {
                // Si es para revisar, vamos a la pantalla de validación
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RendicionValidacionScreen(rendicion: item),
                  ),
                ).then((_) {
                  if (context.mounted) {
                    context
                        .read<RendicionesProvider>()
                        .cargarBandejaValidacion();
                  }
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. CABECERA: Usuario y (Fecha o Acción)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey[100],
                            radius: 12,
                            child: const Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.nombreUsuario,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      // LÓGICA VISUAL: Icono de acción si es pago
                      esParaPago
                          ? Row(
                              children: [
                                Text(
                                  "Toca para Subir ",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.upload_file,
                                  size: 16,
                                  color: Colors.green[800],
                                ),
                              ],
                            )
                          : Text(
                              item.fecha,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 2. TÍTULO: ID y Propósito
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: borderSideColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          idVisual,
                          style: TextStyle(
                            color: borderSideColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.proposito,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  // 3. RESUMEN FINANCIERO (3 Columnas)
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoColumn(
                          "ASIGNADO",
                          asignado,
                          Colors.black87,
                          CrossAxisAlignment.start,
                        ),
                      ),
                      Container(height: 30, width: 1, color: Colors.grey[300]),
                      Expanded(
                        child: _buildInfoColumn(
                          "TOTAL (IVA)",
                          gastado,
                          Colors.blue[700]!,
                          CrossAxisAlignment.center,
                        ),
                      ),
                      Container(height: 30, width: 1, color: Colors.grey[300]),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              esReembolso ? "REEMBOLSO" : "DEVOLUCIÓN",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatMoney(saldo.abs()),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: esReembolso
                                    ? Colors.red[700]
                                    : Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoColumn(
    String label,
    int amount,
    Color color,
    CrossAxisAlignment alignment,
  ) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatMoney(amount),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
