import 'package:flutter/material.dart';

class RoleHelper {
  // --- PARTE VISUAL (ÍCONOS Y COLORES) ---

  static IconData getIconForRole(String roleName) {
    final role = roleName.toLowerCase().trim();

    if (role.contains('admin')) return Icons.admin_panel_settings;
    // OJO: validador ht debe ir antes que validador normal
    if (role.contains('validador ht')) return Icons.more_time;
    if (role.contains('validador')) return Icons.fact_check_outlined;
    if (role.contains('conductor')) return Icons.directions_car;
    // Agregamos usuario y mantenemos rendidor por retrocompatibilidad
    if (role.contains('usuario') || role.contains('rendidor'))
      return Icons.analytics_outlined;

    return Icons.person; // Default
  }

  static Color getColorForRole(String roleName) {
    final role = roleName.toLowerCase().trim();

    if (role.contains('admin')) return Colors.red[700]!;
    // OJO: validador ht debe ir antes que validador normal
    if (role.contains('validador ht')) return Colors.teal[700]!;
    if (role.contains('validador')) return Colors.purple[700]!;
    if (role.contains('conductor')) return Colors.green[700]!;
    // Agregamos usuario y mantenemos rendidor por retrocompatibilidad
    if (role.contains('usuario') || role.contains('rendidor'))
      return Colors.orange[700]!;

    return Colors.grey[600]!;
  }

  // --- PARTE LÓGICA (NUEVAS FUNCIONES PARA PROTEGER VISTAS) ---

  static bool isAdmin(List<String> roles) =>
      roles.any((r) => r.toLowerCase().contains('admin'));

  static bool isConductor(List<String> roles) =>
      roles.any((r) => r.toLowerCase().contains('conductor'));

  // Verifica si es Validador de Gastos (Exactamente "Validador")
  static bool isValidador(List<String> roles) =>
      roles.any((r) => r.toLowerCase().trim() == 'validador');

  // Verifica si es Validador de Hojas de Tiempo
  static bool isValidadorHT(List<String> roles) =>
      roles.any((r) => r.toLowerCase().contains('validador ht'));

  // Verifica si es Usuario (o Rendidor antiguo)
  static bool isUsuario(List<String> roles) => roles.any(
    (r) =>
        r.toLowerCase().contains('usuario') ||
        r.toLowerCase().contains('rendidor'),
  );

  // Comprueba si tiene acceso a pantallas de administración o revisión
  static bool hasAccessToAdminPanel(List<String> roles) {
    return isAdmin(roles) || isValidador(roles) || isValidadorHT(roles);
  }
}
