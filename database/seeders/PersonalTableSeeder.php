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
                'rut' => '18.842.196-2',
                'id_empresa' => 1,
                'correo' => 'ariel.martinez@iaaspa.cl',
                'created_at' => '2026-02-03 19:34:09',
                'updated_at' => '2026-02-03 19:34:09',
            ),
            1 => 
            array (
                'id_personal' => 2,
                'nombre_personal' => 'Camilo',
                'apellido_personal' => 'Arenas',
                'rut' => '10.369.017-K',
                'id_empresa' => 1,
                'correo' => 'camilo.arenas@iaaspa.cl',
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
                'correo' => 'camilo.arenas.c@iaaspa.cl',
                'created_at' => '2026-02-03 19:34:10',
                'updated_at' => '2026-02-03 19:34:10',
            ),
            3 => 
            array (
                'id_personal' => 4,
                'nombre_personal' => 'Cristopher',
                'apellido_personal' => 'Mitchell',
                'rut' => '20.121.153-0',
                'id_empresa' => 1,
                'correo' => 'cristopher.mitchell@iaaspa.cl',
                'created_at' => '2026-02-03 19:34:10',
                'updated_at' => '2026-02-03 19:34:10',
            ),
            4 => 
            array (
                'id_personal' => 5,
                'nombre_personal' => 'Felipe',
                'apellido_personal' => 'Perez',
                'rut' => '20.133.212-5',
                'id_empresa' => 1,
                'correo' => 'felipe.perez@iaaspa.cl',
                'created_at' => '2026-02-03 19:34:10',
                'updated_at' => '2026-02-03 19:34:10',
            ),
            5 => 
            array (
                'id_personal' => 6,
                'nombre_personal' => 'Gabriela',
                'apellido_personal' => 'Lillo',
                'rut' => '16.812.156-3',
                'id_empresa' => 1,
                'correo' => 'gabrielalillog@gmail.com',
                'created_at' => '2026-02-03 19:34:10',
                'updated_at' => '2026-02-03 19:34:10',
            ),
            6 => 
            array (
                'id_personal' => 7,
                'nombre_personal' => 'Italo',
                'apellido_personal' => 'Erazo',
                'rut' => '19.612.052-1',
                'id_empresa' => 1,
                'correo' => 'italo.erazo@iaaspa.cl',
                'created_at' => '2026-02-03 19:34:11',
                'updated_at' => '2026-02-03 19:34:11',
            ),
            7 => 
            array (
                'id_personal' => 8,
                'nombre_personal' => 'Kevin',
                'apellido_personal' => 'Pena y Lillo',
                'rut' => '20.791.274-3',
                'id_empresa' => 1,
                'correo' => 'kevinmplb@gmail.com',
                'created_at' => '2026-02-03 19:34:11',
                'updated_at' => '2026-02-03 19:34:11',
            ),
            8 => 
            array (
                'id_personal' => 9,
                'nombre_personal' => 'Mauricio',
                'apellido_personal' => 'Diaz',
                'rut' => '20.012.250-K',
                'id_empresa' => 1,
                'correo' => 'mauricio.diaz@iaaspa.cl',
                'created_at' => '2026-02-03 19:34:11',
                'updated_at' => '2026-02-03 19:34:11',
            ),
            9 => 
            array (
                'id_personal' => 10,
                'nombre_personal' => 'Martin',
                'apellido_personal' => 'Vielma',
                'rut' => '21.515.005-4',
                'id_empresa' => 1,
                'correo' => 'martin.vielma@iaaspa.cl',
                'created_at' => '2026-02-03 19:34:12',
                'updated_at' => '2026-02-03 19:34:12',
            ),
            10 => 
            array (
                'id_personal' => 11,
                'nombre_personal' => 'Patricio',
                'apellido_personal' => 'Zamora',
                'rut' => '15.999.684-0',
                'id_empresa' => 1,
                'correo' => 'patricio.zamora@iaaspa.cl',
                'created_at' => '2026-02-03 19:34:12',
                'updated_at' => '2026-02-03 19:34:12',
            ),
            11 => 
            array (
                'id_personal' => 12,
                'nombre_personal' => 'Ruben',
                'apellido_personal' => 'Zamora',
                'rut' => '16.890.003-1',
                'id_empresa' => 1,
                'correo' => 'ruben.zamora@iaaspa.cl',
                'created_at' => '2026-02-03 19:34:12',
                'updated_at' => '2026-02-03 19:34:12',
            ),
            12 => 
            array (
                'id_personal' => 13,
                'nombre_personal' => 'Sebastian',
                'apellido_personal' => 'Cortes',
                'rut' => '18.618.901-5',
                'id_empresa' => 1,
                'correo' => 'sebastian.cortes@iaaspa.cl',
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
                'correo' => 'Sin@correo.cl',
                'created_at' => '2026-02-03 19:34:13',
                'updated_at' => '2026-02-10 13:06:49',
            ),
        ));
        
        
    }
}