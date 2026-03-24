import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import '../../data/models/proveedor_model.dart';
import '../providers/proveedor_provider.dart';
import '../widgets/proveedor_dialog.dart';

class ProveedorDetailsScreen extends StatefulWidget {
  final ProveedorModel proveedor;

  const ProveedorDetailsScreen({super.key, required this.proveedor});

  @override
  State<ProveedorDetailsScreen> createState() => _ProveedorDetailsScreenState();
}

class _ProveedorDetailsScreenState extends State<ProveedorDetailsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Escuchamos el provider para actualizar la vista en tiempo real si editamos
    final provider = context.watch<ProveedorProvider>();
    final ProveedorModel currentProv = provider.proveedores.firstWhere(
      (p) => p.idProveedor == widget.proveedor.idProveedor,
      orElse: () => widget.proveedor,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        return Scaffold(
          backgroundColor: isDesktop
              ? const Color(0xFFF4F6F8)
              : const Color(0xFFF8F9FA),

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
                        'Detalle de Proveedor',
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
                    'Detalle de Proveedor',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
          body: isDesktop
              ? _buildDesktopLayout(currentProv)
              : _buildMobileLayout(currentProv),
        );
      },
    );
  }

  // ==========================================================
  // 💻 DISEÑO 1: ESCRITORIO (WEB / PC)
  // ==========================================================
  Widget _buildDesktopLayout(ProveedorModel prov) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Columna Izquierda: Perfil
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(20),
                        ),
                        border: Border(
                          right: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [_buildHeader(prov, isDesktop: true)],
                      ),
                    ),
                  ),
                  // Columna Derecha: Información y Botones
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Información Comercial",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildInfoCard(prov, isDesktop: true),
                          const SizedBox(height: 40),
                          const Text(
                            "Acciones",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildActionButtons(prov, isDesktop: true),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // 📱 DISEÑO 2: MÓVIL
  // ==========================================================
  Widget _buildMobileLayout(ProveedorModel prov) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildHeader(prov, isDesktop: false),
                const SizedBox(height: 24),
                _buildInfoCard(prov, isDesktop: false),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildActionButtons(prov, isDesktop: false),
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildHeader(ProveedorModel prov, {required bool isDesktop}) {
    return Column(
      children: [
        CircleAvatar(
          radius: isDesktop ? 60 : 50,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            prov.nombreProveedor.isNotEmpty
                ? prov.nombreProveedor[0].toUpperCase()
                : '?',
            style: TextStyle(
              fontSize: isDesktop ? 48 : 40,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          prov.nombreProveedor,
          style: TextStyle(
            fontSize: isDesktop ? 24 : 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue),
          ),
          child: Text(
            "PROVEEDOR ACTIVO",
            style: TextStyle(
              color: Colors.blue[800],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // 👇 SECCIÓN CORREGIDA: SE REEMPLAZÓ EL ID POR EL NOMBRE DEL CONTACTO Y RAZÓN SOCIAL 👇
  Widget _buildInfoCard(ProveedorModel prov, {required bool isDesktop}) {
    return Card(
      elevation: isDesktop ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDesktop
            ? BorderSide(color: Colors.grey.shade200)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(
              Icons.business,
              'Razón Social / Empresa',
              prov.nombreProveedor,
            ),
            const Divider(),
            _buildInfoRow(
              Icons.person_outline,
              'Contacto',
              prov.nombreContacto?.isNotEmpty == true
                  ? prov.nombreContacto!
                  : 'Sin registrar',
            ),
            const Divider(),
            _buildInfoRow(
              Icons.phone,
              'Teléfono',
              prov.numeroContacto?.isNotEmpty == true
                  ? prov.numeroContacto!
                  : 'Sin registrar',
            ),
            const Divider(),
            _buildInfoRow(
              Icons.email_outlined,
              'Correo',
              prov.correoContacto?.isNotEmpty == true
                  ? prov.correoContacto!
                  : 'Sin registrar',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ProveedorModel prov, {required bool isDesktop}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: isDesktop ? 55 : 48,
          child: ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => ProveedorDialog(proveedor: prov),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text(
              'Editar Proveedor',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: isDesktop ? 0 : 2,
            ),
          ),
        ),
        SizedBox(height: isDesktop ? 16 : 12),
        SizedBox(
          width: double.infinity,
          height: isDesktop ? 55 : 48,
          child: OutlinedButton.icon(
            onPressed: _isLoading
                ? null
                : () async {
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('¿Eliminar Proveedor?'),
                        content: Text(
                          '¿Deseas eliminar permanentemente a ${prov.nombreProveedor}?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text(
                              'Eliminar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirmar == true) {
                      setState(() => _isLoading = true);
                      final provider = context.read<ProveedorProvider>();
                      final exito = await provider.eliminarProveedor(
                        prov.idProveedor,
                      );

                      if (!mounted) return;
                      setState(() => _isLoading = false);

                      if (exito) {
                        Navigator.pop(context); // Volvemos a la lista
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Proveedor eliminado exitosamente'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              provider.errorMessage ?? 'Error al eliminar',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.delete_outline),
            label: Text(
              _isLoading ? 'Procesando...' : 'Eliminar Proveedor',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red[700],
              side: BorderSide(color: Colors.red.shade200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
