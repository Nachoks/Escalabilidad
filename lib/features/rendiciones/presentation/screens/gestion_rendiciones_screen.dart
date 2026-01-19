import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // <--- IMPORTANTE
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/rendiciones_provider.dart';
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

  // Función para confirmar borrado
  Future<void> _confirmarBorrar(int idRendicion) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar Rendición"),
        content: const Text(
          "¿Estás seguro? Se eliminarán todos los gastos y fotos asociados. Esta acción no se puede deshacer.",
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
              content: Text("Error al eliminar (Verifica que sea Borrador)"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Función placeholder para enviar
  void _enviarRevision(int idRendicion) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Funcionalidad 'Enviar' próximamente...")),
    );
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

                return Slidable(
                  // Clave única para que Slidable funcione bien en listas
                  key: ValueKey(rendicion.idRendicion),

                  // Solo habilitamos el deslizamiento si es editable
                  enabled: esEditable,

                  // Acciones al deslizar a la izquierda (O derecha según prefieras)
                  // startActionPane: ... (Izquierda)

                  // endActionPane: Deslizar de derecha a izquierda
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      // BOTÓN ENVIAR (VERDE)
                      SlidableAction(
                        onPressed: (_) =>
                            _enviarRevision(rendicion.idRendicion!),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        icon: Icons.send,
                        label: 'Enviar',
                      ),
                      // BOTÓN BORRAR (ROJO)
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
                    margin: EdgeInsets.zero, // El margen lo maneja el ListView
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
                            // 1. Cabecera (Fecha y Estado)
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
                                    color: rendicion.estado == 'Borrador'
                                        ? Colors.amber.shade100
                                        : Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    rendicion.estado,
                                    style: TextStyle(
                                      color: rendicion.estado == 'Borrador'
                                          ? Colors.amber.shade900
                                          : Colors.blue.shade900,
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
