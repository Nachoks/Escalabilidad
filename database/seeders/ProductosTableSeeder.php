<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class ProductosTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('productos')->delete();
        
        \DB::table('productos')->insert(array (
            0 => 
            array (
                'id_producto' => 1,
                'id_proveedor' => 1,
                'codigo_producto' => '123456',
                'nombre_producto' => 'Prueba',
                'marca' => 'ABB',
                'created_at' => '2026-03-24 15:39:41',
                'updated_at' => '2026-03-24 15:39:41',
            ),
            1 => 
            array (
                'id_producto' => 2,
                'id_proveedor' => 3,
                'codigo_producto' => '987654',
                'nombre_producto' => 'Prueba 2',
                'marca' => 'NEW ERA',
                'created_at' => '2026-03-24 15:41:05',
                'updated_at' => '2026-03-24 15:41:05',
            ),
            2 => 
            array (
                'id_producto' => 3,
                'id_proveedor' => 4,
                'codigo_producto' => '654987',
                'nombre_producto' => 'Prueba 4',
                'marca' => 'hms',
                'created_at' => '2026-03-26 17:42:36',
                'updated_at' => '2026-03-26 17:42:36',
            ),
        ));
        
        
    }
}