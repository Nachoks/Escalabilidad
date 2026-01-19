import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/rendiciones_provider.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/gasto_provider.dart'; // Necesario para validar gastos
import 'package:somnolence_app/features/rendiciones/presentation/widget/add_rendicion_dialog.dart';
import 'package:somnolence_app/features/rendiciones/presentation/screens/rendicion_detail_screen.dart';

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

  // --- LÓGICA DE ENVÍO CON POPUP INTELIGENTE ---
  Future<void> _prepararEnvio(int idRendicion, int totalMonto) async {
    // 1. Mostrar carga mientras analizamos los gastos
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // 2. Obtener gastos actualizados para verificar fotos
    // Usamos el GastoProvider para traer los datos sin pintar pantalla aun
    final gastoProvider = context.read<GastoProvider>();
    await gastoProvider.cargarGastos(idRendicion);
    final gastos = gastoProvider.gastos;

    // Cerramos el loading
    if (mounted) Navigator.pop(context);

    // 3. Analizar datos
    int cantidadGastos = gastos.length;
    int sinFoto = gastos.where((g) => g.fotos.isEmpty).length;

    if (!mounted) return;

    // 4. Mostrar Popup de Confirmación
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Enviar a Revisión"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Estás a punto de enviar esta rendición."),
            const SizedBox(height: 15),
            _buildResumenRow("Total Gastos:", "$cantidadGastos"),
            _buildResumenRow("Monto Total:", _formatMoney(totalMonto)),
            const SizedBox(height: 15),

            // ADVERTENCIA SI FALTAN FOTOS
            if (sinFoto > 0)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Advertencia: Hay $sinFoto gasto(s) sin evidencia adjunta.",
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Toda la evidencia completa",
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx); // Cerrar popup
              _enviarDefinitivo(idRendicion);
            },
            icon: const Icon(Icons.send, size: 18),
            label: const Text("Enviar Ahora"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _enviarDefinitivo(int idRendicion) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Enviando rendición...")));

    final exito = await context.read<RendicionesProvider>().enviarRendicion(
      idRendicion,
    );

    if (mounted) {
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Rendición enviada exitosamente!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al enviar. Intenta nuevamente."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmarBorrar(int idRendicion) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar Rendición"),
        content: const Text(
          "¿Estás seguro? Se eliminarán todos los gastos y fotos asociados.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      final exito = await context.read<RendicionesProvider>().borrarRendicion(
        idRendicion,
      );

      if (mounted) {
        if (exito) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Rendición eliminada"),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error al eliminar"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rendiciones.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final rendicion = rendiciones[index];

                final bool saldoNegativo = rendicion.saldo < 0;
                final Color colorSaldo = saldoNegativo
                    ? Colors.red
                    : Colors.green;
                final String textoSaldo = saldoNegativo
                    ? "Reembolso: ${_formatMoney(rendicion.saldo.abs())}"
                    : "Devolución: ${_formatMoney(rendicion.saldo)}";

                final String idFormateado = (rendicion.idRendicion ?? 0)
                    .toString()
                    .padLeft(3, '0');

                // Definimos si se puede borrar/enviar (Solo Borradores u Observadas)
                final bool esEditable = [
                  'Borrador',
                  'Observada',
                ].contains(rendicion.estado);

                // --- LÓGICA DE COLOR Y TEXTO DEL BADGE ---
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
                  case 'Aprobada': // <--- AQUÍ ESTÁ EL CAMBIO SOLICITADO
                    badgeColor = Colors.purple.shade100;
                    badgeTextColor = Colors.purple.shade900;
                    badgeText = "POR PAGAR"; // Texto personalizado
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
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => _prepararEnvio(
                          rendicion.idRendicion!,
                          rendicion.totalGastado,
                        ),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        icon: Icons.send,
                        label: 'Enviar',
                      ),
                      SlidableAction(
                        onPressed: (_) =>
                            _confirmarBorrar(rendicion.idRendicion!),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Borrar',
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
                            // 1. Cabecera (Fecha y Badge Estado)
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

                            // 2. Propósito e ID
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      "Saldo",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      textoSaldo,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colorSaldo,
                                      ),
                                    ),
                                  ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No tienes rendiciones",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
