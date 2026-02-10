<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Schema;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Desactivar revisión de claves foráneas
        // Esto permite limpiar las tablas sin que la base de datos reclame por relaciones
        Schema::disableForeignKeyConstraints();

        // 2. Llamar a los seeders UNA SOLA VEZ
        $this->call([
            // --- Maestros principales ---
            EmpresaTableSeeder::class,
            AreasEmpresaTableSeeder::class,
            TipoUsuarioTableSeeder::class,
            
            // --- Personal y Usuarios ---
            PersonalTableSeeder::class,
            UsuariosTableSeeder::class,    // Ojo: verifica si tu archivo se llama UsersTableSeeder o UsuariosTableSeeder
            UsuarioRolTableSeeder::class,
            
            // --- Activos y Clientes ---
            VehiculoTableSeeder::class,
            ClienteTableSeeder::class,
            
            // --- Operación ---
            ServicioTableSeeder::class,
            OcClienteTableSeeder::class,
            HasGuiaTableSeeder::class,
            HasGuiaArchivosTableSeeder::class,
            
            // --- Finanzas ---
            RendicionTableSeeder::class,
            GastoTableSeeder::class,
            GastoArchivoTableSeeder::class,
            
            // --- Otros ---
            RegistrosTableSeeder::class,
        ]);

        // 3. Reactivar las claves foráneas para seguridad futura
        Schema::enableForeignKeyConstraints();
        
        // ¡¡AQUÍ NO DEBES PONER NADA MÁS!!
        $this->call(EmpresaTableSeeder::class);
        $this->call(AreasEmpresaTableSeeder::class);
        $this->call(TipoUsuarioTableSeeder::class);
        $this->call(UsuariosTableSeeder::class);
        $this->call(UsuarioRolTableSeeder::class);
        $this->call(PersonalTableSeeder::class);
        $this->call(VehiculoTableSeeder::class);
        $this->call(ClienteTableSeeder::class);
        $this->call(ServicioTableSeeder::class);
        $this->call(OcClienteTableSeeder::class);
        $this->call(HasGuiaTableSeeder::class);
        $this->call(HasGuiaArchivosTableSeeder::class);
        $this->call(RendicionTableSeeder::class);
        $this->call(GastoTableSeeder::class);
        $this->call(GastoArchivoTableSeeder::class);
        $this->call(RegistrosTableSeeder::class);
    }
}