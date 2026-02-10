<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class GastoArchivoTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('gasto_archivo')->delete();
        
        \DB::table('gasto_archivo')->insert(array (
            0 => 
            array (
                'id_gasto_archivo' => 1,
                'id_gasto' => 1,
                'nombre_original' => 'scaled_ac2eb3b8-7c01-40d0-96dd-2f86b05de0083585276473685273840.jpg',
                'nombre_fisico' => '001-7900.jpg',
                'ruta_relativa' => '001/gastos/001-7900.jpg',
                'extension' => 'jpg',
                'peso_kb' => '475.73',
                'created_at' => '2026-02-09 19:14:26',
                'id_validador' => NULL,
            ),
            1 => 
            array (
                'id_gasto_archivo' => 2,
                'id_gasto' => 2,
                'nombre_original' => 'scaled_7c1e2d24-5bc7-4c1f-80a9-c9666a29816b6810898722655014716.jpg',
                'nombre_fisico' => '002-14880.jpg',
                'ruta_relativa' => '001/gastos/002-14880.jpg',
                'extension' => 'jpg',
                'peso_kb' => '461.58',
                'created_at' => '2026-02-09 19:15:11',
                'id_validador' => NULL,
            ),
            2 => 
            array (
                'id_gasto_archivo' => 3,
                'id_gasto' => 3,
                'nombre_original' => 'scaled_86d2d6b3-15db-4f9d-ac65-c8d4d3462df06294121574367955570.jpg',
                'nombre_fisico' => '003-21980.jpg',
                'ruta_relativa' => '001/gastos/003-21980.jpg',
                'extension' => 'jpg',
                'peso_kb' => '432.30',
                'created_at' => '2026-02-09 19:16:11',
                'id_validador' => NULL,
            ),
            3 => 
            array (
                'id_gasto_archivo' => 4,
                'id_gasto' => 4,
                'nombre_original' => 'scaled_e27a130f-e228-4f31-a4b4-e5d7808a64b93679272529761655120.jpg',
                'nombre_fisico' => '004-21980.jpg',
                'ruta_relativa' => '001/gastos/004-21980.jpg',
                'extension' => 'jpg',
                'peso_kb' => '461.30',
                'created_at' => '2026-02-09 19:17:05',
                'id_validador' => NULL,
            ),
            4 => 
            array (
                'id_gasto_archivo' => 5,
                'id_gasto' => 5,
                'nombre_original' => 'scaled_1508d465-0ffb-4146-a617-7a802010c3c33132971786240051288.jpg',
                'nombre_fisico' => '005-1300.jpg',
                'ruta_relativa' => '001/gastos/005-1300.jpg',
                'extension' => 'jpg',
                'peso_kb' => '321.63',
                'created_at' => '2026-02-09 19:18:00',
                'id_validador' => NULL,
            ),
            5 => 
            array (
                'id_gasto_archivo' => 6,
                'id_gasto' => 6,
                'nombre_original' => 'scaled_e17a8c40-3cda-4874-b388-0c046014d6147487042616351576545.jpg',
                'nombre_fisico' => '006-61490.jpg',
                'ruta_relativa' => '001/gastos/006-61490.jpg',
                'extension' => 'jpg',
                'peso_kb' => '357.73',
                'created_at' => '2026-02-09 19:18:56',
                'id_validador' => NULL,
            ),
            6 => 
            array (
                'id_gasto_archivo' => 7,
                'id_gasto' => 7,
                'nombre_original' => 'scaled_5c0eec0b-f013-4880-8286-33021c1adbb97016983867123971462.jpg',
                'nombre_fisico' => '007-2590.jpg',
                'ruta_relativa' => '001/gastos/007-2590.jpg',
                'extension' => 'jpg',
                'peso_kb' => '392.60',
                'created_at' => '2026-02-09 19:20:05',
                'id_validador' => NULL,
            ),
            7 => 
            array (
                'id_gasto_archivo' => 8,
                'id_gasto' => 8,
                'nombre_original' => 'scaled_297dfa8a-730c-40a9-9e06-c0c3d6cf66557410818716543732741.jpg',
                'nombre_fisico' => '008-5137.jpg',
                'ruta_relativa' => '001/gastos/008-5137.jpg',
                'extension' => 'jpg',
                'peso_kb' => '1544.81',
                'created_at' => '2026-02-09 19:21:14',
                'id_validador' => NULL,
            ),
            8 => 
            array (
                'id_gasto_archivo' => 9,
                'id_gasto' => 9,
                'nombre_original' => 'scaled_04dc32e5-ce60-42bc-951d-0f30d0e2d5404194135811598012480.jpg',
                'nombre_fisico' => '009-4979.jpg',
                'ruta_relativa' => '001/gastos/009-4979.jpg',
                'extension' => 'jpg',
                'peso_kb' => '1930.10',
                'created_at' => '2026-02-09 19:21:56',
                'id_validador' => NULL,
            ),
            9 => 
            array (
                'id_gasto_archivo' => 10,
                'id_gasto' => 12,
                'nombre_original' => 'scaled_1000122231.jpg',
                'nombre_fisico' => '012-150000.jpg',
                'ruta_relativa' => '002/gastos/012-150000.jpg',
                'extension' => 'jpg',
                'peso_kb' => '53.69',
                'created_at' => '2026-02-09 20:15:40',
                'id_validador' => NULL,
            ),
            10 => 
            array (
                'id_gasto_archivo' => 11,
                'id_gasto' => 13,
                'nombre_original' => 'scaled_1000122232.jpg',
                'nombre_fisico' => '013-80000.jpg',
                'ruta_relativa' => '002/gastos/013-80000.jpg',
                'extension' => 'jpg',
                'peso_kb' => '54.67',
                'created_at' => '2026-02-09 20:15:48',
                'id_validador' => NULL,
            ),
            11 => 
            array (
                'id_gasto_archivo' => 13,
                'id_gasto' => 11,
            'nombre_original' => 'Comprobante_Transferencia_a_Terceros_7032873(1).pdf',
                'nombre_fisico' => '011-10000.pdf',
                'ruta_relativa' => '002/gastos/011-10000.pdf',
                'extension' => 'pdf',
                'peso_kb' => '34.46',
                'created_at' => '2026-02-09 20:19:51',
                'id_validador' => NULL,
            ),
            12 => 
            array (
                'id_gasto_archivo' => 14,
                'id_gasto' => 14,
                'nombre_original' => 'scaled_8a6bfff3-62c0-4899-b0c8-a1051b0d0f054147715334875524389.jpg',
                'nombre_fisico' => '014-30619.jpg',
                'ruta_relativa' => '003/gastos/014-30619.jpg',
                'extension' => 'jpg',
                'peso_kb' => '244.38',
                'created_at' => '2026-02-10 14:07:38',
                'id_validador' => NULL,
            ),
            13 => 
            array (
                'id_gasto_archivo' => 16,
                'id_gasto' => 16,
                'nombre_original' => 'scaled_67ee5c5b-c2b1-4786-96b3-42343bea342a5445341602470019780.jpg',
                'nombre_fisico' => '016-16290.jpg',
                'ruta_relativa' => '003/gastos/016-16290.jpg',
                'extension' => 'jpg',
                'peso_kb' => '323.04',
                'created_at' => '2026-02-10 14:11:25',
                'id_validador' => NULL,
            ),
            14 => 
            array (
                'id_gasto_archivo' => 17,
                'id_gasto' => 17,
                'nombre_original' => 'scaled_30a2b2af-c481-4b26-bb44-4f0ac15b1cae825748310364926939.jpg',
                'nombre_fisico' => '017-1434.jpg',
                'ruta_relativa' => '003/gastos/017-1434.jpg',
                'extension' => 'jpg',
                'peso_kb' => '273.46',
                'created_at' => '2026-02-10 14:12:55',
                'id_validador' => NULL,
            ),
            15 => 
            array (
                'id_gasto_archivo' => 18,
                'id_gasto' => 18,
                'nombre_original' => 'scaled_569abf80-b335-4105-83a9-b676c7ebe178920586628936802545.jpg',
                'nombre_fisico' => '018-41470.jpg',
                'ruta_relativa' => '004/gastos/018-41470.jpg',
                'extension' => 'jpg',
                'peso_kb' => '306.45',
                'created_at' => '2026-02-10 15:18:43',
                'id_validador' => NULL,
            ),
            16 => 
            array (
                'id_gasto_archivo' => 19,
                'id_gasto' => 19,
                'nombre_original' => 'scaled_8222c650-0077-4499-9327-3381bebf90c8158462366061876026.jpg',
                'nombre_fisico' => '019-4147.jpg',
                'ruta_relativa' => '004/gastos/019-4147.jpg',
                'extension' => 'jpg',
                'peso_kb' => '343.72',
                'created_at' => '2026-02-10 15:19:05',
                'id_validador' => NULL,
            ),
        ));
        
        
    }
}