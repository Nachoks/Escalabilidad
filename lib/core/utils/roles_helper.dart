import 'package:flutter/material.dart';

class RoleHelper {
  // --- PARTE VISUAL (ÍCONOS Y COLORES) ---

  static IconData getIconForRole(String roleName) {
    final role = roleName.toLowerCase().trim();

    if (role.contains('admin')) return Icons.admin_panel_settings;
    if (role.contains('validador ht')) return Icons.more_time;
    if (role.contains('validador')) return Icons.fact_check_outlined;
    if (role.contains('conductor')) return Icons.directions_car;

    // 👇 NUEVO: Ícono para el rol de inventario
    if (role.contains('inventario')) return Icons.inventory_2_outlined;

    if (role.contains('usuario') || role.contains('rendidor'))
      return Icons.analytics_outlined;

    return Icons.person; // Default
  }

  static Color getColorForRole(String roleName) {
    final role = roleName.toLowerCase().trim();

    if (role.contains('admin')) return Colors.red[700]!;
    if (role.contains('validador ht')) return Colors.teal[700]!;
    if (role.contains('validador')) return Colors.purple[700]!;
    if (role.contains('conductor')) return Colors.green[700]!;

    // 👇 NUEVO: Color para el rol de inventario
    if (role.contains('inventario')) return Colors.blueGrey[700]!;

    if (role.contains('usuario') || role.contains('rendidor'))
      return Colors.orange[700]!;

    return Colors.grey[600]!;
  }

  // --- PARTE LÓGICA (NUEVAS FUNCIONES PARA PROTEGER VISTAS) ---

  static bool isAdmin(List<String> roles) =>
      roles.any((r) => r.toLowerCase().contains('admin'));

  static bool isConductor(List<String> roles) =>
      roles.any((r) => r.toLowerCase().contains('conductor'));

  static bool isValidador(List<String> roles) =>
      roles.any((r) => r.toLowerCase().trim() == 'validador');

  static bool isValidadorHT(List<String> roles) =>
      roles.any((r) => r.toLowerCase().contains('validador ht'));

  // 👇 NUEVO: Función booleana para detectar si tiene el rol de inventario
  static bool isInventario(List<String> roles) =>
      roles.any((r) => r.toLowerCase().contains('inventario'));

  static bool isUsuario(List<String> roles) => roles.any(
    (r) =>
        r.toLowerCase().contains('usuario') ||
        r.toLowerCase().contains('rendidor'),
  );

  static bool hasAccessToAdminPanel(List<String> roles) {
    return isAdmin(roles) || isValidador(roles) || isValidadorHT(roles);
  }
}
