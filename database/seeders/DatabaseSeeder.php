<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Schema; // Importante para desactivar claves foráneas

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Desactivar revisión de claves foráneas para poder limpiar/insertar sin orden estricto
        Schema::disableForeignKeyConstraints();

        // 2. Llamar a los seeders en orden lógico
        $this->call([
            // Maestros principales
            EmpresaTableSeeder::class,       // Crea la empresa base
            AreasEmpresaTableSeeder::class,  // Crea las áreas
            TipoUsuarioTableSeeder::class,   // Crea los roles (Admin, Conductor, etc.)
            
            // Personal y Usuarios
            PersonalTableSeeder::class,      // Crea el personal (nombres, rut)
            UsuariosTableSeeder::class,      // Crea los usuarios (login, pass)
            UsuarioRolTableSeeder::class,    // Asigna roles a usuarios
            
            // Activos y Clientes
            VehiculoTableSeeder::class,
            ClienteTableSeeder::class,
            
            // Operación (Servicios, OCs, Guías)
            ServicioTableSeeder::class,
            OcClienteTableSeeder::class,
            HasGuiaTableSeeder::class,
            HasGuiaArchivosTableSeeder::class,
            
            // Finanzas (Rendiciones)
            RendicionTableSeeder::class,
            GastoTableSeeder::class,
            GastoArchivoTableSeeder::class,
            
            // Otros
            RegistrosTableSeeder::class,
        ]);

        // 3. Reactivar las claves foráneas
        Schema::enableForeignKeyConstraints();
    }
}