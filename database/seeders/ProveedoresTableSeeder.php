<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class ProveedoresTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('proveedores')->delete();
        
        \DB::table('proveedores')->insert(array (
            0 => 
            array (
                'id_proveedor' => 1,
                'nombre_proveedor' => 'ABB Chile',
                'created_at' => '2026-03-31 05:55:30',
                'updated_at' => '2026-03-31 05:55:30',
            ),
            1 => 
            array (
                'id_proveedor' => 2,
                'nombre_proveedor' => 'Rittal',
                'created_at' => '2026-03-31 05:55:30',
                'updated_at' => '2026-03-31 05:55:30',
            ),
            2 => 
            array (
                'id_proveedor' => 3,
                'nombre_proveedor' => 'Phoenix Contact.',
                'created_at' => '2026-03-31 05:55:30',
                'updated_at' => '2026-03-31 05:55:30',
            ),
            3 => 
            array (
                'id_proveedor' => 4,
                'nombre_proveedor' => 'Interlog',
                'created_at' => '2026-03-31 05:55:30',
                'updated_at' => '2026-03-31 05:55:30',
            ),
            4 => 
            array (
                'id_proveedor' => 5,
                'nombre_proveedor' => 'Proveedor Migración',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
        ));
        
        
    }
}