<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class PersonalTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('personal')->delete();
        
        \DB::table('personal')->insert(array (
            0 => 
            array (
                'id_personal' => 1,
                'nombre_personal' => 'Ariel',
                'apellido_personal' => 'Martinez',
                'rut' => '12.345.678-9',
                'id_empresa' => 1,
                'correo' => NULL,
                'created_at' => '2026-02-03 19:34:09',
                'updated_at' => '2026-02-03 19:34:09',
            ),
            1 => 
            array (
                'id_personal' => 2,
                'nombre_personal' => 'Camilo',
                'apellido_personal' => 'Arenas',
                'rut' => '13.456.789-0',
                'id_empresa' => 1,
                'correo' => NULL,
                'created_at' => '2026-02-03 19:34:09',
                'updated_at' => '2026-02-03 19:34:09',
            ),
            2 => 
            array (
                'id_personal' => 3,
                'nombre_personal' => 'Camilo',
                'apellido_personal' => 'Arenas',
                'rut' => '14.567.890-1',
                'id_empresa' => 1,
                'correo' => NULL,
                'created_at' => '2026-02-03 19:34:10',
                'updated_at' => '2026-02-03 19:34:10',
            ),
            3 => 
            array (
                'id_personal' => 4,
                'nombre_personal' => 'Cristopher',
                'apellido_personal' => 'Mitchell',
                'rut' => '15.678.901-2',
                'id_empresa' => 1,
                'correo' => NULL,
                'created_at' => '2026-02-03 19:34:10',
                'updated_at' => '2026-02-03 19:34:10',
            ),
            4 => 
            array (
                'id_personal' => 5,
                'nombre_personal' => 'Felipe',
                'apellido_personal' => 'Perez',
                'rut' => '16.789.012-3',
                'id_empresa' => 1,
                'correo' => NULL,
                'created_at' => '2026-02-03 19:34:10',
                'updated_at' => '2026-02-03 19:34:10',
            ),
            5 => 
            array (
                'id_personal' => 6,
                'nombre_personal' => 'Gabriela',
                'apellido_personal' => 'Lillo',
                'rut' => '17.890.123-4',
                'id_empresa' => 1,
                'correo' => NULL,
                'created_at' => '2026-02-03 19:34:10',
                'updated_at' => '2026-02-03 19:34:10',
            ),
            6 => 
            array (
                'id_personal' => 7,
                'nombre_personal' => 'Italo',
                'apellido_personal' => 'Erazo',
                'rut' => '18.901.234-5',
                'id_empresa' => 1,
                'correo' => NULL,
                'created_at' => '2026-02-03 19:34:11',
                'updated_at' => '2026-02-03 19:34:11',
            ),
            7 => 
            array (
                'id_personal' => 8,
                'nombre_personal' => 'Kevin',
                'apellido_personal' => 'Pena y Lillo',
                'rut' => '19.012.345-6',
                'id_empresa' => 1,
                'correo' => NULL,
                'created_at' => '2026-02-03 19:34:11',
                'updated_at' => '2026-02-03 19:34:11',
            ),
            8 => 
            array (
                'id_personal' => 9,
                'nombre_personal' => 'Mauricio',
                'apellido_personal' => 'Diaz',
                'rut' => '20.123.456-7',
                'id_empresa' => 1,
                'correo' => NULL,
                'created_at' => '2026-02-03 19:34:11',
                'updated_at' => '2026-02-03 19:34:11',
            ),
            9 => 
            array (
                'id_personal' => 10,
                'nombre_personal' => 'Martin',
                'apellido_personal' => 'Vielma',
                'rut' => '21.234.567-8',
                'id_empresa' => 1,
                'correo' => NULL,
                'created_at' => '2026-02-03 19:34:12',
                'updated_at' => '2026-02-03 19:34:12',
            ),
            10 => 
            array (
                'id_personal' => 11,
                'nombre_personal' => 'Patricio',
                'apellido_personal' => 'Zamora',
                'rut' => '22.345.678-9',
                'id_empresa' => 1,
                'correo' => NULL,
                'created_at' => '2026-02-03 19:34:12',
                'updated_at' => '2026-02-03 19:34:12',
            ),
            11 => 
            array (
                'id_personal' => 12,
                'nombre_personal' => 'Ruben',
                'apellido_personal' => 'Zamora',
                'rut' => '23.456.789-0',
                'id_empresa' => 1,
                'correo' => NULL,
                'created_at' => '2026-02-03 19:34:12',
                'updated_at' => '2026-02-03 19:34:12',
            ),
            12 => 
            array (
                'id_personal' => 13,
                'nombre_personal' => 'Sebastian',
                'apellido_personal' => 'Cortes',
                'rut' => '24.567.890-1',
                'id_empresa' => 1,
                'correo' => NULL,
                'created_at' => '2026-02-03 19:34:13',
                'updated_at' => '2026-02-03 19:34:13',
            ),
            13 => 
            array (
                'id_personal' => 14,
                'nombre_personal' => 'Tester',
                'apellido_personal' => 'Tester',
                'rut' => '10.111.222-3',
                'id_empresa' => 1,
                'correo' => NULL,
                'created_at' => '2026-02-03 19:34:13',
                'updated_at' => '2026-02-03 19:34:13',
            ),
        ));
        
        
    }
}