import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb; // <--- Importante para la web
import 'package:intl/intl.dart';
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

  String _formatearFecha(String fechaString) {
    if (fechaString.isEmpty) return "";
    try {
      final DateTime fecha = DateTime.parse(fechaString);
      return DateFormat('dd-MM-yyyy').format(fecha);
    } catch (e) {
      return fechaString;
    }
  }

  // --- LÓGICA DE PAGO (ADAPTADA A WEB) ---
  Future<void> _procesarPago(
    BuildContext context,
    int idRendicion,
    bool isDesktop,
  ) async {
    final picker = ImagePicker();
    String? pathSeleccionado;
    Uint8List? fileBytes;
    String? fileName;

    // Menú de opciones de subida
    Widget menuOpciones = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Adjuntar Comprobante de Transferencia",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        if (!kIsWeb)
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.blue),
            title: const Text("Tomar Foto"),
            onTap: () => Navigator.pop(context, 'camera'),
          ),
        ListTile(
          leading: const Icon(Icons.photo_library, color: Colors.green),
          title: const Text("Galería / Imagen"),
          onTap: () => Navigator.pop(context, 'gallery'),
        ),
        ListTile(
          leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
          title: const Text("Archivo PDF"),
          onTap: () => Navigator.pop(context, 'pdf'),
        ),
      ],
    );

    // 1. Preguntar origen
    String? opcion;
    if (isDesktop) {
      opcion = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: SizedBox(width: 350, child: menuOpciones),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar"),
            ),
          ],
        ),
      );
    } else {
      opcion = await showModalBottomSheet<String>(
        context: context,
        builder: (ctx) => SafeArea(child: menuOpciones),
      );
    }

    if (opcion == null) return;
    if (!mounted) return;

    // 2. Obtener archivo según plataforma
    if (opcion == 'camera' || opcion == 'gallery') {
      final XFile? photo = await picker.pickImage(
        source: opcion == 'camera' ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 60,
      );
      if (photo != null) {
        if (kIsWeb) {
          fileBytes = await photo.readAsBytes();
          fileName = photo.name;
        } else {
          pathSeleccionado = photo.path;
        }
      }
    } else {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: kIsWeb, // Clave para la Web
      );
      if (result != null) {
        if (kIsWeb) {
          fileBytes = result.files.single.bytes;
          fileName = result.files.single.name;
        } else {
          pathSeleccionado = result.files.single.path;
        }
      }
    }

    if (pathSeleccionado == null && fileBytes == null) return;
    if (!mounted) return;

    // 3. Capturamos referencias de UI antes de la llamada asíncrona
    final scaffoldContext = ScaffoldMessenger.of(context);
    final provider = context.read<RendicionesProvider>();

    scaffoldContext.showSnackBar(
      const SnackBar(
        content: Text("Subiendo comprobante..."),
        duration: Duration(seconds: 1),
      ),
    );

    // 4. Subimos a la base de datos
    bool exito = false;
    if (kIsWeb && fileBytes != null && fileName != null) {
      exito = await provider.pagarRendicionWeb(
        idRendicion,
        fileBytes,
        fileName,
      );
    } else if (!kIsWeb && pathSeleccionado != null) {
      exito = await provider.pagarRendicion(idRendicion, pathSeleccionado);
    }

    if (exito) {
      scaffoldContext.showSnackBar(
        const SnackBar(
          content: Text("¡Pago registrado correctamente!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      scaffoldContext.showSnackBar(
        const SnackBar(
          content: Text("Error al subir comprobante. Revisa la consola."),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        return Scaffold(
          backgroundColor: isDesktop
              ? const Color(0xFFF4F6F8)
              : AppColors.background,

          // --- APPBAR ---
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
                        "Gestión de Gastos",
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
                      tooltip: "Recargar",
                      onPressed: () => context
                          .read<RendicionesProvider>()
                          .cargarBandejaValidacion(),
                    ),
                    const SizedBox(width: 16),
                  ],
                  bottom: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 4,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
                )
              : AppBar(
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

          // --- CUERPO ---
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 1200 : double.infinity,
                    ),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildListaRendiciones(
                          listaPorRevisar,
                          esParaPago: false,
                          isDesktop: isDesktop,
                        ),
                        _buildListaRendiciones(
                          listaPorPagar,
                          esParaPago: true,
                          isDesktop: isDesktop,
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  // --- CONSTRUCTOR DE LISTA ---
  Widget _buildListaRendiciones(
    List<RendicionModel> lista, {
    required bool esParaPago,
    required bool isDesktop,
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
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return isDesktop
        ? GridView.builder(
            padding: const EdgeInsets.all(32),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.3, // Formato horizontal de tarjeta
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            itemCount: lista.length,
            itemBuilder: (context, index) =>
                _buildTarjetaRendicion(lista[index], esParaPago, isDesktop),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _buildTarjetaRendicion(lista[index], esParaPago, isDesktop),
          );
  }

  // --- TARJETA INDIVIDUAL ---
  Widget _buildTarjetaRendicion(
    RendicionModel item,
    bool esParaPago,
    bool isDesktop,
  ) {
    final idVisual = "#${(item.idRendicion ?? 0).toString().padLeft(3, '0')}";
    final borderSideColor = esParaPago ? Colors.green : Colors.orange;

    final int asignado = item.montoEntregado;
    final int gastado = item.totalGastado;
    final int saldo = asignado - gastado;
    final bool esReembolso = saldo < 0;

    return Card(
      elevation: isDesktop ? 0 : 3,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderSideColor.withOpacity(0.5), width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (esParaPago) {
            _procesarPago(context, item.idRendicion!, isDesktop);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RendicionValidacionScreen(rendicion: item),
              ),
            ).then((_) {
              if (context.mounted)
                context.read<RendicionesProvider>().cargarBandejaValidacion();
            });
          }
        },
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. CABECERA: Usuario y Acción
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[100],
                        radius: 14,
                        child: const Icon(
                          Icons.person,
                          size: 18,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.nombreUsuario,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  esParaPago
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "SUBIR PAGO ",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.upload_file,
                                size: 14,
                                color: Colors.green[800],
                              ),
                            ],
                          ),
                        )
                      : Text(
                          _formatearFecha(item.fecha),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. TÍTULO: ID y Propósito
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: borderSideColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      idVisual,
                      style: TextStyle(
                        color: borderSideColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.proposito,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if (isDesktop) const Spacer(), // Empuja el resumen al fondo en PC
              if (!isDesktop) const SizedBox(height: 16),
              if (!isDesktop) const Divider(height: 1),
              if (!isDesktop) const SizedBox(height: 16),

              // 3. RESUMEN FINANCIERO
              Container(
                padding: const EdgeInsets.all(12),
                decoration: isDesktop
                    ? BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      )
                    : null,
                child: Row(
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
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatMoney(saldo.abs()),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
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
              ),
            ],
          ),
        ),
      ),
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
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatMoney(amount),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}
