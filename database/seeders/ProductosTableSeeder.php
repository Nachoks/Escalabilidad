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
                'nombre_producto' => 'Pruebas',
                'marca' => 'ABB',
                'created_at' => '2026-03-24 15:39:41',
                'updated_at' => '2026-03-31 22:07:11',
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
            3 => 
            array (
                'id_producto' => 4,
                'id_proveedor' => 1,
                'codigo_producto' => '3BSE041882R1',
                'nombre_producto' => 'escaner939192',
                'marca' => 'Hola',
                'created_at' => '2026-04-01 21:54:43',
                'updated_at' => '2026-04-01 21:54:43',
            ),
            4 => 
            array (
                'id_producto' => 5,
                'id_proveedor' => 4,
                'codigo_producto' => '3BSC610068R1',
                'nombre_producto' => 'escaneo2',
                'marca' => 'alo',
                'created_at' => '2026-04-01 22:32:26',
                'updated_at' => '2026-04-01 22:32:26',
            ),
            5 => 
            array (
                'id_producto' => 6,
                'id_proveedor' => 2,
                'codigo_producto' => '3BSE013234R1',
                'nombre_producto' => 'escaneo 3',
                'marca' => 'kilo',
                'created_at' => '2026-04-01 22:33:34',
                'updated_at' => '2026-04-01 22:33:34',
            ),
            6 => 
            array (
                'id_producto' => 7,
                'id_proveedor' => 4,
                'codigo_producto' => '3BSE008514R1',
                'nombre_producto' => 'escaneo 4',
                'marca' => 'a',
                'created_at' => '2026-04-01 22:34:24',
                'updated_at' => '2026-04-01 22:34:24',
            ),
            7 => 
            array (
                'id_producto' => 8,
                'id_proveedor' => 3,
                'codigo_producto' => '3BSC610066R1',
                'nombre_producto' => 'escaneo 5',
                'marca' => 'ola',
                'created_at' => '2026-04-01 22:36:38',
                'updated_at' => '2026-04-01 22:36:38',
            ),
            8 => 
            array (
                'id_producto' => 9,
                'id_proveedor' => 3,
                'codigo_producto' => '3BSE008512R1',
                'nombre_producto' => 'escaneo 6',
                'marca' => 'Hola',
                'created_at' => '2026-04-02 19:24:59',
                'updated_at' => '2026-04-02 19:24:59',
            ),
            9 => 
            array (
                'id_producto' => 10,
                'id_proveedor' => 3,
                'codigo_producto' => '942134999081031794',
                'nombre_producto' => 'codigo marca nueva',
                'marca' => 'acc',
                'created_at' => '2026-04-02 19:34:29',
                'updated_at' => '2026-04-02 19:34:29',
            ),
            10 => 
            array (
                'id_producto' => 11,
                'id_proveedor' => 3,
                'codigo_producto' => '3BSE052605R1',
                'nombre_producto' => 'producto',
                'marca' => 'alo',
                'created_at' => '2026-04-02 19:44:29',
                'updated_at' => '2026-04-02 19:44:29',
            ),
        ));
        
        
    }
}