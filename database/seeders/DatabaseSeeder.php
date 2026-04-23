<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Schema; // <--- ESTO ES VITAL

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
public function run()
    {
        $this->call([
            // 1. TABLAS BASE (Cero dependencias)
            EmpresaTableSeeder::class,
            TipoUsuarioTableSeeder::class,
            VehiculoTableSeeder::class,
            ClienteTableSeeder::class,
            ProveedoresTableSeeder::class,

            // 2. USUARIOS (Dependen de Empresa y Tipo de Usuario)
            PersonalTableSeeder::class,
            UsuariosTableSeeder::class,
            UsuarioRolTableSeeder::class,

            // 3. CATÁLOGOS SECUNDARIOS (Dependen de clientes y proveedores)
            AreasEmpresaTableSeeder::class,
            ServicioTableSeeder::class,
            OcClienteTableSeeder::class,
            ProductosTableSeeder::class,

            // 4. RENDICIONES (Jerarquía estricta)
            RendicionTableSeeder::class,
            GastoTableSeeder::class,
            GastoArchivoTableSeeder::class,

            // 5. OPERACIONES / SERVICIOS
            HasGuiaTableSeeder::class,
            HasGuiaArchivosTableSeeder::class,
            RegistrosTableSeeder::class,

        
            // 6. HOJAS DE TIEMPO (Jerarquía estricta)
            HojasTiempoSemanasTableSeeder::class,
            HojasTiempoDiariasTableSeeder::class,
            HojasTiempoActividadesTableSeeder::class,

            // 7. INVENTARIO (Jerarquía estricta)
            InventarioProductosTableSeeder::class,
            InventarioEntradasTableSeeder::class,
            InventarioSalidasTableSeeder::class,
        ]);

        $this->call(EmpresaTableSeeder::class);
        $this->call(TipoUsuarioTableSeeder::class);
        $this->call(VehiculoTableSeeder::class);
        $this->call(ClienteTableSeeder::class);
        $this->call(ProveedoresTableSeeder::class);
        $this->call(PersonalTableSeeder::class);
        $this->call(UsuariosTableSeeder::class);
        $this->call(UsuarioRolTableSeeder::class);
        $this->call(AreasEmpresaTableSeeder::class);
        $this->call(ServicioTableSeeder::class);
        $this->call(OcClienteTableSeeder::class);
        $this->call(ProductosTableSeeder::class);
        $this->call(HasGuiaTableSeeder::class);
        $this->call(HasGuiaArchivosTableSeeder::class);
        $this->call(RendicionTableSeeder::class);
        $this->call(GastoTableSeeder::class);
        $this->call(GastoArchivoTableSeeder::class);
        $this->call(RegistrosTableSeeder::class);
        $this->call(HojasTiempoSemanasTableSeeder::class);
        $this->call(HojasTiempoDiariasTableSeeder::class);
        $this->call(HojasTiempoActividadesTableSeeder::class);
    }

}