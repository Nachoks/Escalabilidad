<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class InventarioProductosTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('inventario_productos')->delete();
        
        \DB::table('inventario_productos')->insert(array (
            0 => 
            array (
                'id_inventario' => 1,
                'id_producto' => 1,
                'stock_actual' => 2,
                'stock_minimo' => 1,
                'created_at' => '2026-03-24 15:39:41',
                'updated_at' => '2026-03-29 23:47:52',
            ),
            1 => 
            array (
                'id_inventario' => 2,
                'id_producto' => 2,
                'stock_actual' => 1,
                'stock_minimo' => 2,
                'created_at' => '2026-03-24 15:41:05',
                'updated_at' => '2026-03-29 23:48:01',
            ),
            2 => 
            array (
                'id_inventario' => 3,
                'id_producto' => 3,
                'stock_actual' => 0,
                'stock_minimo' => 0,
                'created_at' => '2026-03-26 17:42:37',
                'updated_at' => '2026-03-26 17:43:39',
            ),
        ));
        
        
    }
}