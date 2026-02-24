import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/features/cuestionarios/presentation/screens/checklist_screen.dart';
import 'package:somnolence_app/features/evaluacion_colores/presentation/screens/reaccion_screen.dart';
import 'package:somnolence_app/features/cuestionarios/presentation/screens/fatiga_screen.dart';
import 'package:somnolence_app/features/cuestionarios/presentation/screens/somnolencia_screen.dart';
import 'package:somnolence_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:somnolence_app/features/auth/data/models/user_model.dart';
import '../providers/home_provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';

class ControlSalidaScreen extends StatelessWidget {
  const ControlSalidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider(),
      child: const _ControlSalidaContent(),
    );
  }
}

class _ControlSalidaContent extends StatefulWidget {
  const _ControlSalidaContent();

  @override
  State<_ControlSalidaContent> createState() => _ControlSalidaContentState();
}

class _ControlSalidaContentState extends State<_ControlSalidaContent> {
  final _patenteArrendadoController = TextEditingController();
  final _descripcionController = TextEditingController();

  final Color _primaryColor = const Color(0xFFF35F34);
  final Color _secondaryColor = const Color.fromARGB(255, 185, 120, 104);

  @override
  void dispose() {
    _patenteArrendadoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _handleRegistrarViaje() async {
    final homeProvider = context.read<HomeProvider>();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario no identificado')),
      );
      return;
    }

    final resultado = await homeProvider.registrarInicioViaje(
      nombreConductor: user.nombreUsuario,
      rutConductor: user.rut,
      patenteManual: _patenteArrendadoController.text,
      descripcion: _descripcionController.text,
    );

    if (!mounted) return;

    if (resultado['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['message']),
          backgroundColor: Colors.green,
        ),
      );
      _patenteArrendadoController.clear();
      _descripcionController.clear();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final homeProvider = context.watch<HomeProvider>();

    if (user == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        return Scaffold(
          backgroundColor: isDesktop
              ? const Color(0xFFF4F6F8)
              : Colors.grey.shade100,

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
                      ), // Usando el isotipo!
                      const SizedBox(width: 16),
                      const Text(
                        "Control de Salida",
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
                    'Control de Salida',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  centerTitle: true,
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_primaryColor, _secondaryColor],
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                      ),
                    ),
                  ),
                ),

          // --- CUERPO ADAPTATIVO ---
          body: isDesktop
              ? _buildDesktopLayout(user, homeProvider)
              : _buildMobileLayout(user, homeProvider),
        );
      },
    );
  }

  // ==========================================================
  // 💻 DISEÑO 1: ESCRITORIO (WEB / PC) - 2 COLUMNAS
  // ==========================================================
  Widget _buildDesktopLayout(User user, HomeProvider homeProvider) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200), // Ancho máximo
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // COLUMNA IZQUIERDA: Info y Vehículo
              Expanded(
                flex: 5,
                child: Column(children: [_buildHeaderInfo(user, homeProvider)]),
              ),
              const SizedBox(width: 32),
              // COLUMNA DERECHA: Tests y Botón de Inicio
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _buildProgressSection(homeProvider),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pruebas Clínicas y Checklists",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildTestsList(homeProvider),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildMainActionButton(homeProvider),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // 📱 DISEÑO 2: MÓVIL (Mantenido exactamente igual)
  // ==========================================================
  Widget _buildMobileLayout(User user, HomeProvider homeProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade100, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          child: Column(
            children: [
              _buildHeaderInfo(user, homeProvider),
              const SizedBox(height: 24),
              _buildProgressSection(homeProvider),
              const SizedBox(height: 24),
              _buildTestsList(homeProvider),
              const SizedBox(height: 32),
              _buildMainActionButton(homeProvider),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES REUTILIZABLES ---
  Widget _buildHeaderInfo(User user, HomeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_ind_outlined, size: 48, color: _primaryColor),
          const SizedBox(height: 10),
          Text(
            user.nombreCompleto,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            user.rut,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const Divider(height: 40),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Seleccione tipo de vehículo:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildVehicleOption(
                  provider,
                  'Empresa',
                  Icons.business_rounded,
                  TipoAuto.empresa,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildVehicleOption(
                  provider,
                  'Arrendado',
                  Icons.car_rental,
                  TipoAuto.arrendado,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (provider.tipoAutoSeleccionado == TipoAuto.empresa)
            _buildDropdownPatentes(provider)
          else if (provider.tipoAutoSeleccionado == TipoAuto.arrendado)
            _buildInputPatenteArrendada(provider),
          if (provider.tipoAutoSeleccionado != null) ...[
            const SizedBox(height: 20),
            TextField(
              controller: _descripcionController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Descripción de la ruta (Opcional)',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ],
          if (provider.direccionGuardada != null) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                "📍 Inicio: ${provider.direccionGuardada}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVehicleOption(
    HomeProvider provider,
    String label,
    IconData icon,
    TipoAuto value,
  ) {
    bool selected = provider.tipoAutoSeleccionado == value;
    return GestureDetector(
      onTap: () {
        provider.setTipoAuto(value);
        _patenteArrendadoController.clear();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? _primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? _primaryColor : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? _primaryColor : Colors.grey.shade400,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? _primaryColor : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownPatentes(HomeProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: provider.cargandoPatentes
              ? const Text('Cargando...')
              : const Text('Seleccionar patente'),
          value: provider.patenteSeleccionada,
          items: provider.patentesDisponibles
              .map(
                (p) => DropdownMenuItem(
                  value: p,
                  child: Text(
                    p,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) => provider.setPatenteSeleccionada(val),
        ),
      ),
    );
  }

  Widget _buildInputPatenteArrendada(HomeProvider provider) {
    return TextField(
      controller: _patenteArrendadoController,
      onChanged: (_) => setState(() {}),
      textCapitalization: TextCapitalization.characters,
      maxLength: 6,
      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
      decoration: InputDecoration(
        hintText: 'Ej: ABCD12',
        counterText: '',
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildProgressSection(HomeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progreso de Tests',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${provider.testsRealizadosCount}/4',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: provider.todosTestsRealizados
                      ? Colors.green
                      : _primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: provider.testsRealizadosCount / 4,
              backgroundColor: Colors.grey.shade200,
              color: provider.todosTestsRealizados
                  ? Colors.green
                  : _primaryColor,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestsList(HomeProvider provider) {
    return Column(
      children: [
        _buildTestButton(
          'Test Somnolencia',
          provider.somnolenciaAprobada,
          () async {
            final res = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SomnolenciaScreen()),
            );
            if (res is bool) provider.setResultadoSomnolencia(res);
          },
        ),
        const SizedBox(height: 16),
        _buildTestButton('Test Fatiga', provider.fatigaAprobada, () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FatigaScreen()),
          );
          if (res is bool) provider.setResultadoFatiga(res);
        }),
        const SizedBox(height: 16),
        _buildTestButton('Test Reacción', provider.reaccionAprobada, () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReaccionScreen()),
          );
          if (res is bool) provider.setResultadoReaccion(res);
        }),
        const SizedBox(height: 16),
        _buildTestButton(
          'Checklist de Ruta',
          provider.checklistAprobado,
          () async {
            final res = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChecklistScreen()),
            );
            if (res is Map<String, dynamic>)
              provider.setResultadoChecklist(res['aprobado'], res['detalles']);
            else if (res is bool)
              provider.setResultadoChecklist(res, null);
          },
        ),
      ],
    );
  }

  Widget _buildTestButton(String text, bool? status, VoidCallback onTap) {
    Color color = status == null
        ? _primaryColor
        : (status ? Colors.green : Colors.orange);
    IconData icon = status == null
        ? Icons.arrow_forward_rounded
        : (status ? Icons.check_circle : Icons.warning_amber_rounded);
    String finalText = status == true
        ? '$text ✓'
        : (status == false ? '$text ⚠' : text);

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: status != null ? color : null,
        gradient: status == null
            ? LinearGradient(colors: [_primaryColor, _secondaryColor])
            : null,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              finalText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainActionButton(HomeProvider provider) {
    bool habilitado = provider.puedeIniciarViaje(
      _patenteArrendadoController.text,
    );
    return Opacity(
      opacity: (habilitado && !provider.cargandoUbicacion) ? 1.0 : 0.5,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF007BFF), Color.fromARGB(255, 84, 143, 206)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF007BFF).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: (habilitado && !provider.cargandoUbicacion)
              ? _handleRegistrarViaje
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: provider.cargandoUbicacion
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Registrar Inicio del Viaje',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}
