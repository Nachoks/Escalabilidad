import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/inventario/presentation/providers/inventario_provider.dart';
// 👇 IMPORTACIÓN DEL NUEVO PROVIDER DE REGLAS 👇
import 'package:somnolence_app/features/inventario/presentation/providers/regla_escaneo_provider.dart';
import 'package:somnolence_app/features/inventario/presentation/widgets/add_producto_dialog.dart';

import 'package:somnolence_app/features/admin/presentation/providers/cliente_provider.dart';
import 'package:somnolence_app/features/admin/presentation/providers/servicio_provider.dart';
import 'package:somnolence_app/features/admin/data/models/cliente_model.dart';
import 'package:somnolence_app/features/admin/data/models/servicio_model.dart';
import 'package:somnolence_app/features/admin/data/models/oc_cliente_model.dart';

class MovilEscanerScreen extends StatefulWidget {
  final bool esEntrada;

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
  OcClienteModel? _ocSeleccionada;

  String _modoEscaneoActual = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Cargamos clientes si es salida
      if (!widget.esEntrada) {
        context.read<ClienteProvider>().cargarClientes();
      }
      // 👇 Carga silenciosa de las reglas dinámicas de escaneo 👇
      context.read<ReglaEscaneoProvider>().cargarReglas();
    });
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _serialController.dispose();
    _ocController.dispose();
    super.dispose();
  }

  // ==========================================
  // EL NUEVO MOTOR DINÁMICO DE ESCANEO
  // ==========================================
  void _procesarCodigoEscaneado(String rawValue) {
    if (_modoEscaneoActual == 'codigo_solo') {
      _codigoController.text = rawValue.trim();
    } else if (_modoEscaneoActual == 'serial_solo') {
      _serialController.text = rawValue.trim();
    } else if (_modoEscaneoActual == 'inteligente') {
      // 1. Limpieza fundamental de basura industrial (ASCII 29 y paréntesis)
      String codigoLimpio = rawValue.replaceAll(String.fromCharCode(29), ' ');
      codigoLimpio = codigoLimpio
          .replaceAll('(', '')
          .replaceAll(')', '')
          .trim();

      String? codigoHallado;
      String? serialHallado;
      bool reconocido = false;

      // 2. Traemos las reglas de la base de datos
      final reglas = context.read<ReglaEscaneoProvider>().reglas;

      if (reglas.isNotEmpty) {
        // --- PROCESAMIENTO DINÁMICO ---
        for (var regla in reglas) {
          // Escapamos los prefijos para que símbolos como "]" no rompan el Regex
          String cod = RegExp.escape(regla.prefijoCodigo);
          String ser = RegExp.escape(regla.prefijoSerie);
          String sep = regla.separadorIgnorar.isNotEmpty
              ? RegExp.escape(regla.separadorIgnorar)
              : '';

          // Muro de contención dinámico (si existe separador, detiene la lectura ahí)
          String muro = sep.isNotEmpty ? '(?:$sep|\$)' : r'$';

          // Creamos todas las permutaciones posibles (porque la cámara a veces lee en desorden)
          String pattern1 = sep.isNotEmpty
              ? '$cod(.*?)$sep.*?$ser(.*)'
              : '$cod(.*?)$ser(.*)'; // COD -> SEP -> SER
          String pattern2 = '$cod(.*?)$ser(.*?)$muro'; // COD -> SER -> MURO
          String pattern3 = '$ser(.*?)$cod(.*?)$muro'; // SER -> COD -> MURO
          String pattern4 = sep.isNotEmpty
              ? '$ser(.*?)$sep.*?$cod(.*)'
              : '$ser(.*?)$cod(.*)'; // SER -> SEP -> COD

          final match1 = RegExp(pattern1).firstMatch(codigoLimpio);
          final match2 = RegExp(pattern2).firstMatch(codigoLimpio);
          final match3 = RegExp(pattern3).firstMatch(codigoLimpio);
          final match4 = RegExp(pattern4).firstMatch(codigoLimpio);

          if (match1 != null) {
            codigoHallado = match1.group(1)?.trim();
            serialHallado = match1.group(2)?.trim();
            reconocido = true;
            break;
          } else if (match2 != null) {
            codigoHallado = match2.group(1)?.trim();
            serialHallado = match2.group(2)?.trim();
            reconocido = true;
            break;
          } else if (match3 != null) {
            serialHallado = match3.group(1)?.trim();
            codigoHallado = match3.group(2)?.trim();
            reconocido = true;
            break;
          } else if (match4 != null) {
            serialHallado = match4.group(1)?.trim();
            codigoHallado = match4.group(2)?.trim();
            reconocido = true;
            break;
          }
        }
      }

      // --- 3. RESPALDO DE SEGURIDAD (FALLBACK) ---
      // Si la BD falló, está vacía, o las reglas del usuario no sirvieron, usamos las confiables:
      if (!reconocido) {
        final m1 = RegExp(r'240(.*?)92.*?21(.*)').firstMatch(codigoLimpio);
        final m2 = RegExp(r'240(.*?)21(.*?)(?:92|$)').firstMatch(codigoLimpio);
        final m3 = RegExp(r'\]C191(.*?)92.*?93(.*)').firstMatch(codigoLimpio);
        final m4 = RegExp(r'93(.*?)91(.*?)(?:92|$)').firstMatch(codigoLimpio);
        final m5 = RegExp(
          r'\]C193(.*?)91(.*?)(?:92|$)',
        ).firstMatch(codigoLimpio);
        final m6 = RegExp(r'91(.*?)93(.*?)(?:92|$)').firstMatch(codigoLimpio);

        if (m1 != null) {
          codigoHallado = m1.group(1)?.trim();
          serialHallado = m1.group(2)?.trim();
          reconocido = true;
        } else if (m2 != null) {
          codigoHallado = m2.group(1)?.trim();
          serialHallado = m2.group(2)?.trim();
          reconocido = true;
        } else if (m3 != null) {
          serialHallado = m3.group(1)?.trim();
          codigoHallado = m3.group(2)?.trim();
          reconocido = true;
        } else if (m4 != null) {
          codigoHallado = m4.group(1)?.trim();
          serialHallado = m4.group(2)?.trim();
          reconocido = true;
        } else if (m5 != null) {
          codigoHallado = m5.group(1)?.trim();
          serialHallado = m5.group(2)?.trim();
          reconocido = true;
        } else if (m6 != null) {
          serialHallado = m6.group(1)?.trim();
          codigoHallado = m6.group(2)?.trim();
          reconocido = true;
        }
      }

      // 4. RESULTADO FINAL
      if (reconocido && codigoHallado != null && serialHallado != null) {
        _codigoController.text = codigoHallado;
        _serialController.text = serialHallado;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Formato reconocido exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _codigoController.text = rawValue.trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Formato no configurado. Ingrese los datos manualmente o configure una nueva regla.',
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
      if (_servicioSeleccionado!.ocs.isNotEmpty && _ocSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debe seleccionar una Orden de Compra')),
        );
        return;
      }

      bool exito = await provider.registrarSalida(
        serial: ser,
        idCliente: _clienteSeleccionado!.idCliente ?? 0,
        ocCliente: _ocSeleccionada?.codOcCliente,
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
                      _ocSeleccionada = null;
                    });

                    if (val != null && val.idCliente != null) {
                      context
                          .read<ServicioProvider>()
                          .cargarServiciosPorCliente(val.idCliente!);
                    }
                  },
                ),
              const SizedBox(height: 20),

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
                        _ocSeleccionada = null;
                      });
                    },
                  ),
                const SizedBox(height: 20),

                if (_servicioSeleccionado != null) ...[
                  if (_servicioSeleccionado!.ocs.isEmpty)
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
                          _ocSeleccionada = val;
                        });
                      },
                    ),
                  const SizedBox(height: 15),
                ],
              ],
            ],
            const SizedBox(height: 20),

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
