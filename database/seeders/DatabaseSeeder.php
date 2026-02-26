<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Schema; // <--- ESTO ES VITAL

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Desactivar protección de claves foráneas
        Schema::disableForeignKeyConstraints();

        // 2. Llamar a los seeders generados por iseed
        // El orden ideal es: Tablas padres -> Tablas hijas
        $this->call([
            // Maestros principales
            EmpresaTableSeeder::class,       
            AreasEmpresaTableSeeder::class,  
            TipoUsuarioTableSeeder::class,   
            
            // Personal y Usuarios (Aquí va tu admin intocable que iseed respaldó)
            PersonalTableSeeder::class,      
            UsuariosTableSeeder::class,     
            UsuarioRolTableSeeder::class,    
            
            // Activos y Clientes
            VehiculoTableSeeder::class,
            ClienteTableSeeder::class,
            
            // Operación
            ServicioTableSeeder::class,
            OcClienteTableSeeder::class,
            HasGuiaTableSeeder::class,
            HasGuiaArchivosTableSeeder::class,
            
            // Finanzas (Rendiciones y Gastos)
            RendicionTableSeeder::class,
            GastoTableSeeder::class,
            GastoArchivoTableSeeder::class,
            
            // Otros
            RegistrosTableSeeder::class,
        ]);

        // 3. Volver a activar la protección
        Schema::enableForeignKeyConstraints();

        
    }
}