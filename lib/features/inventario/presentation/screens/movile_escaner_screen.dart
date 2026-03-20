import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/inventario/presentation/providers/inventario_provider.dart';
import 'package:somnolence_app/features/inventario/presentation/widgets/add_producto_dialog.dart';

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

  // Opciones de escaneo para saber qué botón apretó el usuario
  String _modoEscaneoActual = '';

  @override
  void dispose() {
    _codigoController.dispose();
    _serialController.dispose();
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
      // BATERÍA DE REGLAS BASADA EN TUS ESTRUCTURAS REALES
      final List<Map<String, String>> reglas = [
        // 1. Estructura: (93)3BSE041882R1(91)SC07167442(92)C
        // Busca lo que hay después del (93) hasta el próximo paréntesis, y lo mismo con el (91)
        {'cod': r'\(93\)([^\(]+)', 'ser': r'\(91\)([^\(]+)'},

        // 2. Estructura: (240)3BSE092693R1(92)B(21)SE252102TP
        // Busca lo que hay después del (240) hasta el próximo paréntesis, y lo mismo con el (21)
        {'cod': r'\(240\)([^\(]+)', 'ser': r'\(21\)([^\(]+)'},
      ];

      bool reconocido = false;

      // El sistema prueba cada regla rápidamente
      for (var regla in reglas) {
        RegExp expCodigo = RegExp(regla['cod']!);
        RegExp expSerial = RegExp(regla['ser']!);

        String? codMatch = expCodigo.firstMatch(rawValue)?.group(1);
        String? serMatch = expSerial.firstMatch(rawValue)?.group(1);

        if (codMatch != null && serMatch != null) {
          _codigoController.text = codMatch.trim();
          _serialController.text = serMatch.trim();
          reconocido = true;
          break; // Rompemos el ciclo porque ya encontramos la estructura correcta
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
        // Fallback: Si no calza con ninguna de las 2 reglas, pegamos todo en "Código"
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

  // ==========================================
  // ABRIR LA CÁMARA EN UN MODAL BOTTOM SHEET
  // ==========================================
  void _abrirEscaner(String modo) {
    setState(() => _modoEscaneoActual = modo);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height:
              MediaQuery.of(context).size.height *
              0.75, // Ocupa el 75% de la pantalla
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
                  // Forzamos al escáner a leer absolutamente todos los formatos (QR, 1D, DataMatrix)
                  controller: MobileScannerController(
                    formats: const [BarcodeFormat.all],
                  ),
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty &&
                        barcodes.first.rawValue != null) {
                      final String code = barcodes.first.rawValue!;
                      Navigator.pop(context); // Cierra la cámara
                      _procesarCodigoEscaneado(code); // Traduce el código
                    }
                  },
                ),
              ),
              // Mira decorativa (Rectangular para que sirva mejor con Códigos de Barra)
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85, // Ancho
                  height: 180, // Más bajo para parecer lector de pistola
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

    if (cod.isEmpty || ser.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, extraiga el Código y el Serial de la caja.',
          ),
        ),
      );
      return;
    }

    if (widget.esEntrada) {
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
      );

      if (exito && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Entrada registrada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      bool exito = await provider.registrarSalida(
        serial: ser,
        idCliente: 1,
      ); // ID temporal

      if (exito && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🛫 Salida registrada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventarioProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.esEntrada ? 'Ingreso a Bodega' : 'Despacho de Equipo',
        ),
        // Ahora todo usa tu color primario corporativo
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // BOTÓN GIGANTE ESCANEO INTELIGENTE
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

            // CAMPO CÓDIGO PRODUCTO (Oculto en Salidas)
            if (widget.esEntrada) ...[
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
              const SizedBox(height: 20),
            ],

            // CAMPO NÚMERO DE SERIE (Siempre visible)
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
