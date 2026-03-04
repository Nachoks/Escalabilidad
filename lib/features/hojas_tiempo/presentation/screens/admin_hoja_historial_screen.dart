import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/hoja_tiempo_provider.dart';
import '../../data/models/hoja_tiempo_model.dart';
import 'hoja_detail_screen.dart';
import '../../../../core/constants/app_colors.dart';

class AdminHojaHistorialScreen extends StatefulWidget {
  const AdminHojaHistorialScreen({super.key});

  @override
  State<AdminHojaHistorialScreen> createState() =>
      _AdminHojaHistorialScreenState();
}

class _AdminHojaHistorialScreenState extends State<AdminHojaHistorialScreen> {
  String _filtroEstado = 'Todos';
  String _selectedPersonal = 'Todos';
  DateTime? _fechaInicioFiltro;
  DateTime? _fechaFinFiltro;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HojaTiempoProvider>().cargarHistorialAdmin();
    });
  }

  // Función para abrir el calendario y elegir rango de fechas
  Future<void> _seleccionarRangoFechas() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _fechaInicioFiltro != null && _fechaFinFiltro != null
          ? DateTimeRange(start: _fechaInicioFiltro!, end: _fechaFinFiltro!)
          : null,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fechaInicioFiltro = picked.start;
        _fechaFinFiltro = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HojaTiempoProvider>();

    // 1. Extraer nombres únicos del personal para el Dropdown
    List<String> nombresPersonal = ['Todos'];
    if (provider.adminHistorial.isNotEmpty) {
      final Set<String> unicos = provider.adminHistorial
          .map((e) => e.nombrePersonal ?? "S/I")
          .toSet();
      final List<String> ordenados = unicos.toList()..sort();
      nombresPersonal.addAll(ordenados);
    }

    // Seguridad: si el seleccionado ya no existe en la lista, volver a 'Todos'
    if (!nombresPersonal.contains(_selectedPersonal)) {
      _selectedPersonal = 'Todos';
    }

    // 2. Lógica de filtrado combinado (Personal + Fechas + Estado)
    final listaFiltrada = provider.adminHistorial.where((semana) {
      // Filtro por Personal
      final coincidePersonal =
          _selectedPersonal == 'Todos' ||
          (semana.nombrePersonal ?? "S/I") == _selectedPersonal;

      // Filtro por Estado
      final coincideEstado =
          _filtroEstado == 'Todos' ||
          semana.estado.toLowerCase() == _filtroEstado.toLowerCase();

      // Filtro por Rango de Fechas
      bool coincideFecha = true;
      if (_fechaInicioFiltro != null && _fechaFinFiltro != null) {
        DateTime fechaSemana =
            DateTime.tryParse(semana.fechaInicio) ?? DateTime.now();

        // Comparamos ignorando las horas (reseteando a medianoche para exactitud)
        DateTime fechaPura = DateTime(
          fechaSemana.year,
          fechaSemana.month,
          fechaSemana.day,
        );
        DateTime inicioPuro = DateTime(
          _fechaInicioFiltro!.year,
          _fechaInicioFiltro!.month,
          _fechaInicioFiltro!.day,
        );
        DateTime finPuro = DateTime(
          _fechaFinFiltro!.year,
          _fechaFinFiltro!.month,
          _fechaFinFiltro!.day,
        );

        coincideFecha =
            (fechaPura.isAtSameMomentAs(inicioPuro) ||
                fechaPura.isAfter(inicioPuro)) &&
            (fechaPura.isAtSameMomentAs(finPuro) ||
                fechaPura.isBefore(finPuro));
      }

      return coincidePersonal && coincideEstado && coincideFecha;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 2,
        toolbarHeight: 70,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            const Image(
              image: AssetImage('assets/images/isotipo.png'),
              width: 45,
              height: 45,
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                "Historial Global HCT",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Actualizar',
            onPressed: () => provider.cargarHistorialAdmin(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          _buildFiltrosAvanzados(nombresPersonal),
          _buildSelectorFiltrosEstados(),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : listaFiltrada.isEmpty
                ? _buildEstadoVacio()
                : LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 800) {
                        return _buildVistaWeb(listaFiltrada);
                      }
                      return _buildVistaMovil(listaFiltrada);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- NUEVA SECCIÓN DE FILTROS AVANZADOS ---
  Widget _buildFiltrosAvanzados(List<String> nombresPersonal) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Dropdown de Personal
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPersonal,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                  ),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  items: nombresPersonal.map((String nombre) {
                    return DropdownMenuItem<String>(
                      value: nombre,
                      child: Text(nombre),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedPersonal = val);
                    }
                  },
                ),
              ),
            ),

            // Botón de Selector de Fechas
            InkWell(
              onTap: _seleccionarRangoFechas,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _fechaInicioFiltro == null
                          ? "Todas las fechas"
                          : "${DateFormat('dd/MM/yy').format(_fechaInicioFiltro!)} - ${DateFormat('dd/MM/yy').format(_fechaFinFiltro!)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Botón para Limpiar Filtros
            if (_selectedPersonal != 'Todos' || _fechaInicioFiltro != null)
              IconButton(
                icon: const Icon(Icons.filter_alt_off),
                color: Colors.redAccent,
                tooltip: "Limpiar filtros",
                onPressed: () {
                  setState(() {
                    _selectedPersonal = 'Todos';
                    _fechaInicioFiltro = null;
                    _fechaFinFiltro = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorFiltrosEstados() {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ['Todos', 'Aprobada', 'Rechazada'].map((estado) {
            final seleccionado = _filtroEstado == estado;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  estado,
                  style: TextStyle(
                    color: seleccionado ? Colors.white : Colors.black87,
                    fontWeight: seleccionado
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                selected: seleccionado,
                onSelected: (val) {
                  if (val) setState(() => _filtroEstado = estado);
                },
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // VISTA MÓVIL
  Widget _buildVistaMovil(List<HojaTiempoSemana> lista) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: lista.length,
      itemBuilder: (context, index) => _buildCardHistorial(lista[index]),
    );
  }

  // VISTA WEB
  Widget _buildVistaWeb(List<HojaTiempoSemana> lista) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 1200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DataTable(
            showCheckboxColumn: false,
            headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
            columns: const [
              DataColumn(
                label: Text(
                  'Personal',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Cliente',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Estado',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Fecha Inicio',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Acciones',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: lista.map((semana) {
              final bool esAprobada = semana.estado.toLowerCase() == 'aprobada';
              final colorEstado = esAprobada ? Colors.green : Colors.red;

              DateTime fechaFormateada =
                  DateTime.tryParse(semana.fechaInicio) ?? DateTime.now();

              return DataRow(
                onSelectChanged: (_) => _verDetalle(semana),
                cells: [
                  DataCell(Text(semana.nombrePersonal ?? "S/I")),
                  DataCell(Text(semana.nombreCliente ?? "S/I")),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorEstado.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        semana.estado.toUpperCase(),
                        style: TextStyle(
                          color: colorEstado,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(DateFormat('dd/MM/yyyy').format(fechaFormateada)),
                  ),
                  DataCell(Icon(Icons.chevron_right, color: AppColors.primary)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHistorial(HojaTiempoSemana semana) {
    final bool esAprobada = semana.estado.toLowerCase() == 'aprobada';
    final Color colorEstado = esAprobada ? Colors.green : Colors.red;

    final String nombre = semana.nombrePersonal ?? "Usuario S/I";
    final String inicial = nombre.isNotEmpty
        ? nombre.substring(0, 1).toUpperCase()
        : "?";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: colorEstado.withOpacity(0.1),
          child: Text(
            inicial,
            style: TextStyle(
              color: colorEstado,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          nombre,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            semana.nombreCliente ?? "S/I",
            style: TextStyle(color: Colors.grey[600], height: 1.3),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.chevron_right, color: AppColors.primary)],
        ),
        onTap: () => _verDetalle(semana),
      ),
    );
  }

  void _verDetalle(HojaTiempoSemana semana) {
    if (semana.idHojaSemana != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HojaDetailScreen(idHojaSemana: semana.idHojaSemana!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se encontró el ID de la hoja.'),
        ),
      );
    }
  }

  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No hay registros con estos filtros",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
