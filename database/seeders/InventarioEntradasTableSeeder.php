<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class InventarioEntradasTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('inventario_entradas')->delete();
        
        \DB::table('inventario_entradas')->insert(array (
            0 => 
            array (
                'id_entrada' => 1,
                'id_producto' => 1,
                'id_responsable' => 14,
                'oc_proveedor' => NULL,
                'serial' => '654321',
                'estado_serial' => 'Entregado',
                'created_at' => '2026-03-24 15:39:41',
                'updated_at' => '2026-03-25 21:06:52',
            ),
            1 => 
            array (
                'id_entrada' => 2,
                'id_producto' => 1,
                'id_responsable' => 14,
                'oc_proveedor' => NULL,
                'serial' => '987654',
                'estado_serial' => 'Entregado',
                'created_at' => '2026-03-24 15:39:55',
                'updated_at' => '2026-03-25 21:11:24',
            ),
            2 => 
            array (
                'id_entrada' => 3,
                'id_producto' => 1,
                'id_responsable' => 14,
                'oc_proveedor' => NULL,
                'serial' => '987654321',
                'estado_serial' => 'Disponible',
                'created_at' => '2026-03-24 15:40:05',
                'updated_at' => '2026-03-24 15:40:05',
            ),
            3 => 
            array (
                'id_entrada' => 4,
                'id_producto' => 2,
                'id_responsable' => 14,
                'oc_proveedor' => NULL,
                'serial' => '654987',
                'estado_serial' => 'Disponible',
                'created_at' => '2026-03-24 15:41:05',
                'updated_at' => '2026-03-24 15:41:05',
            ),
            4 => 
            array (
                'id_entrada' => 5,
                'id_producto' => 1,
                'id_responsable' => 14,
                'oc_proveedor' => '123335',
                'serial' => '741852',
                'estado_serial' => 'Disponible',
                'created_at' => '2026-03-25 21:06:13',
                'updated_at' => '2026-03-25 21:06:13',
            ),
            5 => 
            array (
                'id_entrada' => 6,
                'id_producto' => 3,
                'id_responsable' => 14,
                'oc_proveedor' => '85296',
                'serial' => '258369',
                'estado_serial' => 'Entregado',
                'created_at' => '2026-03-26 17:42:37',
                'updated_at' => '2026-03-26 17:43:39',
            ),
        ));
        
        
    }
}