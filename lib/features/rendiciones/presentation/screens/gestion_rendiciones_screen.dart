import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/rendiciones_provider.dart';
import 'package:somnolence_app/features/rendiciones/presentation/widget/add_rendicion_dialog.dart';

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
    // Cargar datos al entrar a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RendicionesProvider>().cargarMisRendiciones();
    });
  }

  // Formateador simple de dinero
  String _formatMoney(int amount) {
    return "\$${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RendicionesProvider>();
    final rendiciones = provider.rendiciones;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Mis Rendiciones"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // AQUÍ IRÁ EL DIÁLOGO DE CREACIÓN (Lo haremos en el siguiente paso)
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

                // Lógica visual para el saldo
                final bool saldoNegativo =
                    rendicion.saldo < 0; // Gasté más de lo que me dieron
                final Color colorSaldo = saldoNegativo
                    ? Colors.red
                    : Colors.green;
                final String textoSaldo = saldoNegativo
                    ? "Reembolso: ${_formatMoney(rendicion.saldo.abs())}"
                    : "Devolución: ${_formatMoney(rendicion.saldo)}";

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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

                        // 2. Propósito y Centro de Costo
                        Text(
                          rendicion.proposito,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (rendicion.centroCosto != null)
                          Text(
                            "CC: ${rendicion.centroCosto}",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
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
