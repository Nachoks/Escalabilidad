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
                'stock_minimo' => 2,
                'created_at' => '2026-03-24 15:39:41',
                'updated_at' => '2026-04-02 19:41:13',
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
            3 => 
            array (
                'id_inventario' => 4,
                'id_producto' => 4,
                'stock_actual' => 3,
                'stock_minimo' => 0,
                'created_at' => '2026-04-01 21:54:43',
                'updated_at' => '2026-04-02 19:23:45',
            ),
            4 => 
            array (
                'id_inventario' => 5,
                'id_producto' => 5,
                'stock_actual' => 0,
                'stock_minimo' => 0,
                'created_at' => '2026-04-01 22:32:26',
                'updated_at' => '2026-04-01 22:32:47',
            ),
            5 => 
            array (
                'id_inventario' => 6,
                'id_producto' => 6,
                'stock_actual' => 1,
                'stock_minimo' => 0,
                'created_at' => '2026-04-01 22:33:35',
                'updated_at' => '2026-04-01 22:33:35',
            ),
            6 => 
            array (
                'id_inventario' => 7,
                'id_producto' => 7,
                'stock_actual' => 1,
                'stock_minimo' => 0,
                'created_at' => '2026-04-01 22:34:24',
                'updated_at' => '2026-04-01 22:34:24',
            ),
            7 => 
            array (
                'id_inventario' => 8,
                'id_producto' => 8,
                'stock_actual' => 1,
                'stock_minimo' => 0,
                'created_at' => '2026-04-01 22:36:38',
                'updated_at' => '2026-04-01 22:36:38',
            ),
            8 => 
            array (
                'id_inventario' => 9,
                'id_producto' => 9,
                'stock_actual' => 0,
                'stock_minimo' => 0,
                'created_at' => '2026-04-02 19:24:59',
                'updated_at' => '2026-04-02 19:45:00',
            ),
            9 => 
            array (
                'id_inventario' => 10,
                'id_producto' => 10,
                'stock_actual' => 1,
                'stock_minimo' => 0,
                'created_at' => '2026-04-02 19:34:29',
                'updated_at' => '2026-04-02 19:34:29',
            ),
            10 => 
            array (
                'id_inventario' => 11,
                'id_producto' => 11,
                'stock_actual' => 1,
                'stock_minimo' => 0,
                'created_at' => '2026-04-02 19:44:29',
                'updated_at' => '2026-04-02 19:44:29',
            ),
        ));
        
        
    }
}