<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class InventarioSalidasTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('inventario_salidas')->delete();
        
        \DB::table('inventario_salidas')->insert(array (
            0 => 
            array (
                'id_salida' => 1,
                'id_entrada' => 1,
                'id_producto' => 1,
                'id_cliente' => 4,
                'id_responsable' => 14,
                'oc_cliente' => '4901984572',
                'serial' => '654321',
                'created_at' => '2026-03-25 21:06:52',
                'updated_at' => '2026-03-25 21:06:52',
            ),
            1 => 
            array (
                'id_salida' => 2,
                'id_entrada' => 2,
                'id_producto' => 1,
                'id_cliente' => 4,
                'id_responsable' => 14,
                'oc_cliente' => '4702808972',
                'serial' => '987654',
                'created_at' => '2026-03-25 21:11:24',
                'updated_at' => '2026-03-25 21:11:24',
            ),
            2 => 
            array (
                'id_salida' => 3,
                'id_entrada' => 6,
                'id_producto' => 3,
                'id_cliente' => 2,
                'id_responsable' => 14,
                'oc_cliente' => '4510215937',
                'serial' => '258369',
                'created_at' => '2026-03-26 17:43:39',
                'updated_at' => '2026-03-26 17:43:39',
            ),
        ));
        
        
    }
}