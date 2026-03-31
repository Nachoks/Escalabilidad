import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // 👇 NUEVA LIBRERÍA
import 'package:somnolence_app/core/constants/app_colors.dart';
import '../../data/models/proveedor_model.dart';
import '../../data/models/contacto_proveedor_model.dart';
import '../providers/proveedor_provider.dart';
import '../widgets/proveedor_dialog.dart';
import '../widgets/contacto_proveedor_dialog.dart'; // 👇 IMPORTAR POP-UP DE CONTACTOS

class ProveedorDetailsScreen extends StatefulWidget {
  final ProveedorModel proveedor;

  const ProveedorDetailsScreen({super.key, required this.proveedor});

  @override
  State<ProveedorDetailsScreen> createState() => _ProveedorDetailsScreenState();
}

class _ProveedorDetailsScreenState extends State<ProveedorDetailsScreen> {
  bool _isLoading = false;

  // Lógica para eliminar un contacto específico y actualizar la base de datos
  Future<void> _eliminarContacto(
    BuildContext context,
    ProveedorModel prov,
    int indexContacto,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar Contacto?'),
        content: Text(
          '¿Seguro que deseas eliminar a ${prov.contactos[indexContacto].nombreContacto}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() => _isLoading = true);

      // Clonamos la lista y quitamos el contacto
      List<ContactoProveedorModel> nuevaLista = List.from(prov.contactos);
      nuevaLista.removeAt(indexContacto);

      // Creamos el proveedor actualizado
      final proveedorActualizado = ProveedorModel(
        idProveedor: prov.idProveedor,
        nombreProveedor: prov.nombreProveedor,
        contactos: nuevaLista,
      );

      final provider = context.read<ProveedorProvider>();
      final exito = await provider.guardarProveedor(proveedorActualizado);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contacto eliminado'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ?? 'Error al eliminar contacto',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        'Detalle de Empresa',
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
                    'Detalle de Empresa',
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

          // 👇 BOTÓN FLOTANTE PARA AGREGAR CONTACTO 👇
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text(
              "Agregar Contacto",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    ContactoProveedorDialog(proveedorOriginal: currentProv),
              );
            },
          ),

          body: Stack(
            children: [
              isDesktop
                  ? _buildDesktopLayout(currentProv)
                  : _buildMobileLayout(currentProv),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // 💻 DISEÑO 1: ESCRITORIO
  // ==========================================================
  Widget _buildDesktopLayout(ProveedorModel prov) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna Izquierda: Perfil y Botones
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(32),
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
                  child: Column(
                    children: [
                      _buildHeader(prov, isDesktop: true),
                      const SizedBox(height: 32),
                      _buildActionButtons(prov, isDesktop: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 32),
              // Columna Derecha: Contactos
              Expanded(
                flex: 7,
                child: Container(
                  padding: const EdgeInsets.all(32),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Lista de Contactos",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Divider(height: 32),
                      _buildContactosList(prov, isDesktop: true),
                    ],
                  ),
                ),
              ),
            ],
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
            padding: const EdgeInsets.fromLTRB(
              16,
              24,
              16,
              100,
            ), // Espacio extra abajo para el FAB
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _buildHeader(prov, isDesktop: false)),
                const SizedBox(height: 32),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 16),
                  child: Text(
                    "Contactos Registrados",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                _buildContactosList(prov, isDesktop: false),
              ],
            ),
          ),
        ),
        // Botones de acción al fondo en móvil
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

  // 👇 NUEVA SECCIÓN DE CONTACTOS 👇
  Widget _buildContactosList(ProveedorModel prov, {required bool isDesktop}) {
    if (prov.contactos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(
                Icons.contact_mail_outlined,
                size: 60,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                "No hay contactos registrados.",
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Desactiva scroll interno
      itemCount: prov.contactos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final contacto = prov.contactos[index];

        // 💻 SI ES ESCRITORIO: Tarjeta normal con botones visibles
        if (isDesktop) {
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: AppColors.secondary.withOpacity(0.2),
                child: const Icon(Icons.person, color: AppColors.secondary),
              ),
              title: Text(
                contacto.nombreContacto,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (contacto.numeroContacto != null)
                      Text("📞 ${contacto.numeroContacto!}"),
                    if (contacto.correoContacto != null)
                      Text("✉️ ${contacto.correoContacto!}"),
                  ],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () =>
                        _mostrarModalEdicionContacto(prov, contacto, index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _eliminarContacto(context, prov, index),
                  ),
                ],
              ),
            ),
          );
        }

        // 📱 SI ES MÓVIL: Tarjeta interactiva con Slidable (deslizar)
        return Slidable(
          key: ValueKey(contacto.idContacto ?? index.toString()),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (_) =>
                    _mostrarModalEdicionContacto(prov, contacto, index),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Editar',
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              SlidableAction(
                onPressed: (_) => _eliminarContacto(context, prov, index),
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
            elevation: 1,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: AppColors.secondary.withOpacity(0.2),
                child: const Icon(Icons.person, color: AppColors.secondary),
              ),
              title: Text(
                contacto.nombreContacto,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  if (contacto.numeroContacto != null)
                    Text(
                      "📞 ${contacto.numeroContacto!}",
                      style: const TextStyle(fontSize: 13),
                    ),
                  if (contacto.correoContacto != null)
                    Text(
                      "✉️ ${contacto.correoContacto!}",
                      style: const TextStyle(fontSize: 13),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _mostrarModalEdicionContacto(
    ProveedorModel prov,
    ContactoProveedorModel contacto,
    int index,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ContactoProveedorDialog(
        proveedorOriginal: prov,
        contactoAEditar: contacto,
        indexContacto: index,
      ),
    );
  }

  Widget _buildActionButtons(ProveedorModel prov, {required bool isDesktop}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: isDesktop ? 50 : 48,
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
              'Editar Empresa',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: isDesktop ? 50 : 48,
          child: OutlinedButton.icon(
            onPressed: _isLoading
                ? null
                : () async {
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('¿Eliminar Proveedor?'),
                        content: Text(
                          '¿Deseas eliminar permanentemente a ${prov.nombreProveedor}? Se perderán todos sus contactos.',
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
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Proveedor eliminado'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(provider.errorMessage ?? 'Error'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
            icon: const Icon(Icons.delete_outline),
            label: const Text(
              'Eliminar Empresa',
              style: TextStyle(fontWeight: FontWeight.bold),
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
