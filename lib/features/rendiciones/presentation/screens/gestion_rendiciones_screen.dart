import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/rendiciones_provider.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/gasto_provider.dart';
import 'package:somnolence_app/features/rendiciones/presentation/widget/add_rendicion_dialog.dart';
import 'package:somnolence_app/features/rendiciones/presentation/screens/rendicion_detail_screen.dart';
import 'package:somnolence_app/features/rendiciones/presentation/widget/edit_rendicion_dialog.dart';

class GestionRendicionesScreen extends StatefulWidget {
  const GestionRendicionesScreen({super.key});

  @override
  State<GestionRendicionesScreen> createState() =>
      _GestionRendicionesScreenState();
}

class _GestionRendicionesScreenState extends State<GestionRendicionesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RendicionesProvider>().cargarMisRendiciones();
    });
  }

  String _formatMoney(int amount) {
    return "\$${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  // --- WIDGET PRIVADO PARA CALCULAR Y MOSTRAR SALDO ---
  Widget _buildSaldoWidget(int montoEntregado, int totalGastado) {
    final int saldoMatematico = montoEntregado - totalGastado;
    final bool esReembolso = saldoMatematico < 0;
    final int valorMostrar = saldoMatematico.abs();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          esReembolso ? "REEMBOLSO" : "DEVOLUCIÓN",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        Text(
          _formatMoney(valorMostrar),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: esReembolso ? Colors.redAccent : Colors.green[700],
          ),
        ),
      ],
    );
  }

  // --- LÓGICA DE ENVÍO CON BLOQUEO DE SEGURIDAD ---
  Future<void> _prepararEnvio(int idRendicion, int totalMonto) async {
    // 1. Mostrar carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // 2. Obtener gastos actualizados
    final gastoProvider = context.read<GastoProvider>();
    await gastoProvider.cargarGastos(idRendicion);
    final gastos = gastoProvider.gastos;

    // Cerrar carga
    if (mounted) Navigator.pop(context);

    // --- BLOQUEO DE SEGURIDAD ---
    // Verificamos si hay gastos rechazados
    bool hayRechazados = gastos.any((g) => g.estado == 'Rechazado');

    if (hayRechazados) {
      if (!mounted) return;

      // ALERTA DE BLOQUEO
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.block, color: Colors.red),
              SizedBox(width: 10),
              Text("Envío Bloqueado"),
            ],
          ),
          content: const Text(
            "Esta rendición contiene gastos que fueron RECHAZADOS anteriormente.\n\n"
            "Por normativa, debes ELIMINAR los gastos rechazados antes de volver a enviar la rendición a revisión.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "Entendido",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
      return; // DETIENE EL PROCESO AQUÍ
    }
    // --- FIN BLOQUEO ---

    // 3. Analizar estadísticas para el resumen
    int cantidadGastos = gastos.length;
    int sinFoto = gastos.where((g) => g.fotos.isEmpty).length;

    // Validación extra: No enviar vacíos
    if (cantidadGastos == 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No puedes enviar una rendición sin gastos."),
        ),
      );
      return;
    }

    if (!mounted) return;

    // 4. Popup de Confirmación Final
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Enviar a Revisión"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Estás a punto de enviar esta rendición."),
            const SizedBox(height: 15),
            Text("Total Gastos: $cantidadGastos"),
            Text("Monto Total: ${_formatMoney(totalMonto)}"),
            const SizedBox(height: 15),
            if (sinFoto > 0)
              Text(
                "⚠️ Advertencia: Hay $sinFoto gastos sin foto.",
                style: TextStyle(color: Colors.orange[800]),
              )
            else
              Text(
                "✅ Evidencia completa",
                style: TextStyle(color: Colors.green[700]),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _enviarDefinitivo(idRendicion);
            },
            child: const Text("Enviar"),
          ),
        ],
      ),
    );
  }

  Future<void> _enviarDefinitivo(int idRendicion) async {
    await context.read<RendicionesProvider>().enviarRendicion(idRendicion);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Procesado")));
    }
  }

  Future<void> _confirmarBorrar(int idRendicion) async {
    await context.read<RendicionesProvider>().borrarRendicion(idRendicion);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RendicionesProvider>();
    final rendiciones = provider.rendiciones;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Mis Rendiciones",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const AddRendicionDialog(),
          );
        },
        label: const Text("Nueva Rendición"),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : rendiciones.isEmpty
          ? Center(
              child: Text(
                "No tienes rendiciones",
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rendiciones.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final rendicion = rendiciones[index];
                final String idFormateado = (rendicion.idRendicion ?? 0)
                    .toString()
                    .padLeft(3, '0');

                final bool esEditable = [
                  'Borrador',
                  'Observada',
                ].contains(rendicion.estado);

                // Configuración de Badges
                Color badgeColor;
                Color badgeTextColor;
                String badgeText = rendicion.estado;

                switch (rendicion.estado) {
                  case 'Borrador':
                    badgeColor = Colors.amber.shade100;
                    badgeTextColor = Colors.amber.shade900;
                    break;
                  case 'Pendiente de Validación':
                    badgeColor = Colors.blue.shade100;
                    badgeTextColor = Colors.blue.shade900;
                    break;
                  case 'Aprobada':
                    badgeColor = Colors.purple.shade100;
                    badgeTextColor = Colors.purple.shade900;
                    badgeText = "POR PAGAR";
                    break;
                  case 'Pagada':
                    badgeColor = Colors.green.shade100;
                    badgeTextColor = Colors.green.shade800;
                    break;
                  case 'Observada':
                    badgeColor = Colors.red.shade100;
                    badgeTextColor = Colors.red.shade900;
                    break;
                  default:
                    badgeColor = Colors.grey.shade200;
                    badgeTextColor = Colors.black54;
                }

                return Slidable(
                  key: ValueKey(rendicion.idRendicion),
                  enabled: esEditable,

                  // Configuración del panel de acciones (Enviar / Borrar)
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 0.7,
                    children: [
                      SlidableAction(
                        onPressed: (_) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => EditRendicionDialog(
                              rendicion:
                                  rendicion, // <--- Pasamos la rendición actual
                            ),
                          );
                        },
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Editar',
                      ),
                      SlidableAction(
                        onPressed: (_) =>
                            _confirmarBorrar(rendicion.idRendicion!),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Borrar',
                      ),

                      SlidableAction(
                        onPressed: (_) => _prepararEnvio(
                          rendicion.idRendicion!,
                          rendicion.totalGastado,
                        ),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        icon: Icons.send,
                        label: 'Enviar',
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                    ],
                  ),

                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 2,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RendicionDetailScreen(rendicion: rendicion),
                          ),
                        );
                        if (mounted) {
                          context
                              .read<RendicionesProvider>()
                              .cargarMisRendiciones();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Cabecera (Fecha y Badge)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  rendicion.fecha,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: badgeColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    badgeText.toUpperCase(),
                                    style: TextStyle(
                                      color: badgeTextColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // 2. Título (ID y Propósito)
                            Row(
                              children: [
                                Text(
                                  "#$idFormateado",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    rendicion.proposito,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            if (rendicion.centroCosto != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  "${rendicion.centroCosto}",
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            const Divider(height: 24),

                            // 3. Resumen Financiero
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Gastado",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      _formatMoney(rendicion.totalGastado),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                // Widget de saldo
                                _buildSaldoWidget(
                                  rendicion.montoEntregado,
                                  rendicion.totalGastado,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
