<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class ClienteTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('cliente')->delete();
        
        \DB::table('cliente')->insert(array (
            0 => 
            array (
                'id_cliente' => 1,
                'cod_cliente' => '00',
                'nombre_cliente' => 'Arenas & Arenas',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-03 19:58:42',
                'updated_at' => '2026-02-03 19:58:42',
            ),
            1 => 
            array (
                'id_cliente' => 2,
                'cod_cliente' => '01',
                'nombre_cliente' => 'Minera Centinela',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-03 19:58:56',
                'updated_at' => '2026-02-03 19:58:56',
            ),
            2 => 
            array (
                'id_cliente' => 3,
                'cod_cliente' => '02',
                'nombre_cliente' => 'Softys',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-03 19:59:13',
                'updated_at' => '2026-02-03 19:59:13',
            ),
            3 => 
            array (
                'id_cliente' => 4,
                'cod_cliente' => '03',
                'nombre_cliente' => 'CMPC Pulp',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-05 15:35:22',
                'updated_at' => '2026-02-05 15:35:22',
            ),
            4 => 
            array (
                'id_cliente' => 5,
                'cod_cliente' => '04',
                'nombre_cliente' => 'BHP',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-05 16:19:29',
                'updated_at' => '2026-02-05 16:19:29',
            ),
            5 => 
            array (
                'id_cliente' => 6,
                'cod_cliente' => '05',
                'nombre_cliente' => 'Codelco',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-05 16:36:22',
                'updated_at' => '2026-02-05 16:36:22',
            ),
            6 => 
            array (
                'id_cliente' => 7,
                'cod_cliente' => '06',
                'nombre_cliente' => 'VOITH',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-05 18:24:50',
                'updated_at' => '2026-02-05 18:24:50',
            ),
            7 => 
            array (
                'id_cliente' => 8,
                'cod_cliente' => '07',
                'nombre_cliente' => 'Austral Tecnologias',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-05 18:27:45',
                'updated_at' => '2026-02-05 18:27:45',
            ),
            8 => 
            array (
                'id_cliente' => 9,
                'cod_cliente' => '08',
                'nombre_cliente' => 'EKA',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-05 18:28:58',
                'updated_at' => '2026-02-05 18:28:58',
            ),
            9 => 
            array (
                'id_cliente' => 10,
                'cod_cliente' => '09',
                'nombre_cliente' => 'Engine Energia',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-05 18:42:45',
                'updated_at' => '2026-02-05 18:42:45',
            ),
            10 => 
            array (
                'id_cliente' => 11,
                'cod_cliente' => '10',
                'nombre_cliente' => 'Vantaz',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-05 19:02:48',
                'updated_at' => '2026-02-05 19:02:48',
            ),
            11 => 
            array (
                'id_cliente' => 12,
                'cod_cliente' => '11',
                'nombre_cliente' => 'STI',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-05 19:03:45',
                'updated_at' => '2026-02-05 19:03:45',
            ),
            12 => 
            array (
                'id_cliente' => 13,
                'cod_cliente' => '12',
                'nombre_cliente' => 'Teknica Chile',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-05 19:39:06',
                'updated_at' => '2026-02-05 19:39:06',
            ),
            13 => 
            array (
                'id_cliente' => 14,
                'cod_cliente' => '13',
                'nombre_cliente' => 'Tractebel',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-05 19:40:50',
                'updated_at' => '2026-02-05 19:40:50',
            ),
            14 => 
            array (
                'id_cliente' => 15,
                'cod_cliente' => '14',
                'nombre_cliente' => 'Enercon',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-05 19:42:20',
                'updated_at' => '2026-02-05 19:42:20',
            ),
            15 => 
            array (
                'id_cliente' => 16,
                'cod_cliente' => '15',
                'nombre_cliente' => 'Polpaico',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-05 19:47:43',
                'updated_at' => '2026-02-05 19:47:43',
            ),
            16 => 
            array (
                'id_cliente' => 17,
                'cod_cliente' => '16',
                'nombre_cliente' => 'Vertycal',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-05 19:53:35',
                'updated_at' => '2026-02-05 19:53:35',
            ),
            17 => 
            array (
                'id_cliente' => 18,
                'cod_cliente' => '17',
                'nombre_cliente' => 'Konecranes',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-05 19:55:41',
                'updated_at' => '2026-02-05 19:55:41',
            ),
            18 => 
            array (
                'id_cliente' => 19,
                'cod_cliente' => '18',
                'nombre_cliente' => 'Panimex',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-05 19:56:04',
                'updated_at' => '2026-02-05 19:58:40',
            ),
            19 => 
            array (
                'id_cliente' => 20,
                'cod_cliente' => '19',
                'nombre_cliente' => 'Tunning',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-05 19:57:48',
                'updated_at' => '2026-02-05 20:03:15',
            ),
            20 => 
            array (
                'id_cliente' => 21,
                'cod_cliente' => '20',
                'nombre_cliente' => 'Teleconsultores',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-05 20:28:28',
                'updated_at' => '2026-02-05 20:28:28',
            ),
            21 => 
            array (
                'id_cliente' => 22,
                'cod_cliente' => '21',
                'nombre_cliente' => 'Layex',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-05 20:30:16',
                'updated_at' => '2026-02-05 20:30:16',
            ),
        ));
        
        
    }
}