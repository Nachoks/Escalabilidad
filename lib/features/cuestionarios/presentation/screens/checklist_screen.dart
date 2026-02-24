// Archivo: checklist_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import '../providers/checklist_provider.dart';
import '../../data/models/checklist_model.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChecklistProvider(),
      child: const _ChecklistContent(),
    );
  }
}

class _ChecklistContent extends StatelessWidget {
  const _ChecklistContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChecklistProvider>();

    void submitForm() {
      final data = provider.getDataForSubmit();
      final allChecked = provider.allChecked;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            allChecked
                ? '¡Verificación completa!'
                : 'Guardando con observaciones...',
          ),
          backgroundColor: allChecked ? Colors.green : Colors.orange,
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (context.mounted) {
          Navigator.pop(context, data);
        }
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        return Scaffold(
          backgroundColor: isDesktop ? const Color(0xFFF4F6F8) : Colors.white,

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
                        "Checklist Pre-Ruta",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  iconTheme: const IconThemeData(color: Colors.white),
                )
              : AppBar(
                  title: const Text(
                    'Checklist Pre-Ruta',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
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
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1000 : double.infinity,
              ), // Centrado en PC
              child: Column(
                children: [
                  // --- BARRA DE PROGRESO ---
                  Container(
                    margin: EdgeInsets.all(isDesktop ? 30 : 20),
                    padding: const EdgeInsets.all(24),
                    decoration: isDesktop
                        ? BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: Colors.grey.shade200),
                          )
                        : null, // En móvil se queda sin caja para aprovechar espacio
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Estado de verificación",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${(provider.progress * 100).toInt()}%",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: provider.allChecked
                                    ? Colors.green
                                    : Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: provider.progress,
                            backgroundColor: Colors.grey[200],
                            color: provider.allChecked
                                ? Colors.green
                                : Colors.blueAccent,
                            minHeight: 12,
                          ),
                        ),
                        if (!provider.allChecked)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Colors.orange.shade700,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "Nota: Los ítems no marcados se registrarán como pendientes.",
                                    style: TextStyle(
                                      color: Colors.orange.shade800,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  if (!isDesktop) const Divider(height: 1),

                  // --- LISTA DE CHECKBOXES ---
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 30 : 0,
                      ),
                      decoration: isDesktop
                          ? BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              border: Border.all(color: Colors.grey.shade200),
                            )
                          : null,
                      child: isDesktop
                          // DISEÑO PARA PC: 2 COLUMNAS
                          ? GridView.builder(
                              padding: const EdgeInsets.all(24),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, // Dos columnas
                                    childAspectRatio:
                                        6, // Para que sean rectangulares
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 10,
                                  ),
                              itemCount: provider.items.length,
                              itemBuilder: (context, index) {
                                CheckItem item = provider.items[index];
                                return _buildCheckboxItem(item, index, context);
                              },
                            )
                          // DISEÑO PARA MÓVIL: 1 COLUMNA (LISTA NORMAL)
                          : ListView.separated(
                              itemCount: provider.items.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                CheckItem item = provider.items[index];
                                return _buildCheckboxItem(item, index, context);
                              },
                            ),
                    ),
                  ),

                  // --- BOTÓN DE CONTINUAR ---
                  Container(
                    margin: EdgeInsets.fromLTRB(
                      isDesktop ? 30 : 0,
                      0,
                      isDesktop ? 30 : 0,
                      isDesktop ? 30 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: isDesktop
                          ? const BorderRadius.vertical(
                              bottom: Radius.circular(16),
                            )
                          : null,
                      border: isDesktop
                          ? Border.all(color: Colors.grey.shade200)
                          : null,
                      boxShadow: [
                        if (!isDesktop)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: SizedBox(
                          width: double.infinity,
                          height: 60, // Un poco más alto
                          child: ElevatedButton(
                            onPressed: submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: provider.allChecked
                                  ? const Color(0xFFF35F34)
                                  : Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              provider.allChecked
                                  ? 'CONFIRMAR Y VOLVER'
                                  : 'CONFIRMAR CON OBSERVACIONES',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Extraemos el Checkbox a un widget para reutilizarlo en la grilla y en la lista
  Widget _buildCheckboxItem(CheckItem item, int index, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: item.isChecked
            ? Colors.green.withOpacity(0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CheckboxListTile(
        title: Text(
          item.title,
          style: TextStyle(
            fontWeight: item.isChecked ? FontWeight.bold : FontWeight.normal,
            color: item.isChecked ? Colors.green.shade800 : Colors.black87,
          ),
        ),
        value: item.isChecked,
        activeColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onChanged: (bool? value) {
          context.read<ChecklistProvider>().toggleItem(index, value ?? false);
        },
      ),
    );
  }
}
