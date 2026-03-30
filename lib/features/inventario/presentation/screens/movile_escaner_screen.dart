import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/inventario/presentation/providers/inventario_provider.dart';
import 'package:somnolence_app/features/inventario/presentation/widgets/add_producto_dialog.dart';

import 'package:somnolence_app/features/admin/presentation/providers/cliente_provider.dart';
import 'package:somnolence_app/features/admin/presentation/providers/servicio_provider.dart';
import 'package:somnolence_app/features/admin/data/models/cliente_model.dart';
import 'package:somnolence_app/features/admin/data/models/servicio_model.dart';
// 👇 AÑADIDO: Importamos el modelo de OC Cliente
import 'package:somnolence_app/features/admin/data/models/oc_cliente_model.dart';

class MovilEscanerScreen extends StatefulWidget {
  final bool esEntrada; // true = Ingreso a bodega, false = Despacho a cliente

  const MovilEscanerScreen({Key? key, required this.esEntrada})
    : super(key: key);

  @override
  State<MovilEscanerScreen> createState() => _MovilEscanerScreenState();
}

class _MovilEscanerScreenState extends State<MovilEscanerScreen> {
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _serialController = TextEditingController();
  final TextEditingController _ocController = TextEditingController();

  ClienteModel? _clienteSeleccionado;
  ServicioModel? _servicioSeleccionado;
  // 👇 MODIFICADO: Ahora es un objeto en lugar de un String
  OcClienteModel? _ocSeleccionada;

  String _modoEscaneoActual = '';

  @override
  void initState() {
    super.initState();
    if (!widget.esEntrada) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ClienteProvider>().cargarClientes();
      });
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _serialController.dispose();
    _ocController.dispose();
    super.dispose();
  }

  // ==========================================
  // LÓGICA DEL ANALIZADOR INTELIGENTE (REGEX)
  // ==========================================
  void _procesarCodigoEscaneado(String rawValue) {
    if (_modoEscaneoActual == 'codigo_solo') {
      _codigoController.text = rawValue;
    } else if (_modoEscaneoActual == 'serial_solo') {
      _serialController.text = rawValue;
    } else if (_modoEscaneoActual == 'inteligente') {
      final List<Map<String, String>> reglas = [
        {'cod': r'\(93\)([^\(]+)', 'ser': r'\(91\)([^\(]+)'},
        {'cod': r'\(240\)([^\(]+)', 'ser': r'\(21\)([^\(]+)'},
      ];

      bool reconocido = false;

      for (var regla in reglas) {
        RegExp expCodigo = RegExp(regla['cod']!);
        RegExp expSerial = RegExp(regla['ser']!);

        String? codMatch = expCodigo.firstMatch(rawValue)?.group(1);
        String? serMatch = expSerial.firstMatch(rawValue)?.group(1);

        if (codMatch != null && serMatch != null) {
          _codigoController.text = codMatch.trim();
          _serialController.text = serMatch.trim();
          reconocido = true;
          break;
        }
      }

      if (reconocido) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Formato reconocido exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _codigoController.text = rawValue;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Formato desconocido. Use los botones pequeños si es un código de barras individual.',
            ),
            backgroundColor: Colors.orange[800],
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _abrirEscaner(String modo) {
    setState(() => _modoEscaneoActual = modo);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
                child: MobileScanner(
                  controller: MobileScannerController(
                    formats: const [BarcodeFormat.all],
                  ),
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty &&
                        barcodes.first.rawValue != null) {
                      final String code = barcodes.first.rawValue!;
                      Navigator.pop(context);
                      _procesarCodigoEscaneado(code);
                    }
                  },
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              const Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Text(
                  'Apunte al Código de Barras o QR\n(Aleje un poco el celular si es muy largo)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // FLUJO PRINCIPAL: GUARDAR EN LARAVEL
  // ==========================================
  void _guardarMovimiento() async {
    final provider = Provider.of<InventarioProvider>(context, listen: false);

    final cod = _codigoController.text.trim();
    final ser = _serialController.text.trim();

    if (ser.isEmpty || (widget.esEntrada && cod.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete los campos de escaneo requeridos.'),
        ),
      );
      return;
    }

    if (widget.esEntrada) {
      final ocManual = _ocController.text.trim();
      bool existe = await provider.verificarCodigoProducto(cod);

      if (!existe) {
        final bool? seCreo = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => AddProductoDialog(codigoEscaneado: cod),
        );
        if (seCreo != true) return;
      }

      bool exito = await provider.registrarEntrada(
        codigoProducto: cod,
        serial: ser,
        ocProveedor: ocManual.isNotEmpty ? ocManual : null,
      );

      _manejarRespuesta(
        exito,
        provider.errorMessage,
        '✅ Entrada registrada con éxito',
      );
    } else {
      if (_clienteSeleccionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debe seleccionar un Cliente')),
        );
        return;
      }
      if (_servicioSeleccionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debe seleccionar un Servicio')),
        );
        return;
      }
      // 👇 AÑADIDO: Validamos que haya escogido una OC si es que existen
      if (_servicioSeleccionado!.ocs.isNotEmpty && _ocSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debe seleccionar una Orden de Compra')),
        );
        return;
      }

      bool exito = await provider.registrarSalida(
        serial: ser,
        idCliente: _clienteSeleccionado!.idCliente ?? 0,
        ocCliente: _ocSeleccionada
            ?.codOcCliente, // Pasamos el string de la OC si existe
      );

      _manejarRespuesta(
        exito,
        provider.errorMessage,
        '🛫 Salida registrada con éxito',
      );
    }
  }

  void _manejarRespuesta(bool exito, String? error, String mensajeExito) {
    if (exito && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensajeExito), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Error en la operación'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventarioProvider>(context);

    final clienteProv = !widget.esEntrada
        ? Provider.of<ClienteProvider>(context)
        : null;
    final servicioProv = !widget.esEntrada
        ? Provider.of<ServicioProvider>(context)
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.esEntrada ? 'Ingreso a Bodega' : 'Despacho de Equipo',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner, size: 45),
              label: const Text(
                'ESCANEO INTELIGENTE\n(Recomendado)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 25),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
              ),
              onPressed: () => _abrirEscaner('inteligente'),
            ),

            const SizedBox(height: 35),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'O ingreso manual',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 25),

            if (widget.esEntrada) ...[
              TextField(
                controller: _ocController,
                decoration: InputDecoration(
                  labelText: 'Orden de Compra (Proveedor)',
                  prefixIcon: const Icon(
                    Icons.receipt_long,
                    color: AppColors.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codigoController,
                      decoration: InputDecoration(
                        labelText: 'Código de Artículo (Modelo)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      onPressed: () => _abrirEscaner('codigo_solo'),
                      tooltip: 'Escanear solo Código',
                    ),
                  ),
                ],
              ),
            ] else ...[
              // MODO SALIDA: DROPDOWN CLIENTES
              if (clienteProv!.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<ClienteModel>(
                  decoration: InputDecoration(
                    labelText: 'Seleccionar Cliente Destino',
                    prefixIcon: const Icon(
                      Icons.business,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: _clienteSeleccionado,
                  items: clienteProv.clientes.map((cliente) {
                    return DropdownMenuItem(
                      value: cliente,
                      child: Text(cliente.nombreCliente),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _clienteSeleccionado = val;
                      _servicioSeleccionado = null;
                      _ocSeleccionada =
                          null; // 🛠️ CORRECCIÓN: Reseteamos la OC al cambiar Cliente
                    });

                    if (val != null && val.idCliente != null) {
                      context
                          .read<ServicioProvider>()
                          .cargarServiciosPorCliente(val.idCliente!);
                    }
                  },
                ),
              const SizedBox(height: 20),

              // MODO SALIDA: DROPDOWN SERVICIOS (Filtrados por Cliente)
              if (_clienteSeleccionado != null) ...[
                if (servicioProv!.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  DropdownButtonFormField<ServicioModel>(
                    decoration: InputDecoration(
                      labelText: 'Seleccionar Servicio Asociado',
                      prefixIcon: const Icon(
                        Icons.handyman,
                        color: AppColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    value: _servicioSeleccionado,
                    items: servicioProv.servicios.map((servicio) {
                      return DropdownMenuItem(
                        value: servicio,
                        child: Text(servicio.nombreServicio),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _servicioSeleccionado = val;
                        _ocSeleccionada =
                            null; // 🛠️ CORRECCIÓN: Reseteamos la OC al cambiar de Servicio
                      });
                    },
                  ),
                const SizedBox(height: 20),

                // 👇 MODO SALIDA: NUEVO DROPDOWN OC (Filtrados por Servicio) 👇
                if (_servicioSeleccionado != null) ...[
                  if (_servicioSeleccionado!.ocs.isEmpty)
                    // Si el servicio no tiene OCs, le mostramos un aviso al usuario
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade800,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Este servicio no tiene Órdenes de Compra asociadas.',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    // Si sí tiene OCs, lo obligamos a elegir con un Dropdown
                    DropdownButtonFormField<OcClienteModel>(
                      decoration: InputDecoration(
                        labelText: 'Seleccionar Orden de Compra',
                        prefixIcon: const Icon(
                          Icons.receipt_long,
                          color: AppColors.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      value: _ocSeleccionada,
                      items: _servicioSeleccionado!.ocs.map((oc) {
                        return DropdownMenuItem(
                          value: oc,
                          child: Text(oc.codOcCliente),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _ocSeleccionada = val; // Guardamos la OC seleccionada
                        });
                      },
                    ),
                  const SizedBox(height: 15),
                ],
              ],
            ],
            const SizedBox(height: 20),

            // CAMPO NÚMERO DE SERIE (Siempre visible para ambos)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _serialController,
                    decoration: InputDecoration(
                      labelText: 'Número de Serie Físico (SN)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    onPressed: () => _abrirEscaner('serial_solo'),
                    tooltip: 'Escanear solo Serie',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // BOTON GUARDAR
            provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _guardarMovimiento,
                    child: const Text(
                      'CONFIRMAR REGISTRO',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
