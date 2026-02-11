<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class UsuarioRolTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('usuario_rol')->delete();
        
        \DB::table('usuario_rol')->insert(array (
            0 => 
            array (
                'id_usuario' => 1,
                'id_tipo_usuario' => 2,
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            1 => 
            array (
                'id_usuario' => 2,
                'id_tipo_usuario' => 2,
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            2 => 
            array (
                'id_usuario' => 3,
                'id_tipo_usuario' => 2,
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            3 => 
            array (
                'id_usuario' => 4,
                'id_tipo_usuario' => 2,
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            4 => 
            array (
                'id_usuario' => 5,
                'id_tipo_usuario' => 2,
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            5 => 
            array (
                'id_usuario' => 6,
                'id_tipo_usuario' => 2,
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            6 => 
            array (
                'id_usuario' => 7,
                'id_tipo_usuario' => 2,
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            7 => 
            array (
                'id_usuario' => 8,
                'id_tipo_usuario' => 2,
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            8 => 
            array (
                'id_usuario' => 9,
                'id_tipo_usuario' => 2,
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            9 => 
            array (
                'id_usuario' => 10,
                'id_tipo_usuario' => 2,
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            10 => 
            array (
                'id_usuario' => 11,
                'id_tipo_usuario' => 2,
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            11 => 
            array (
                'id_usuario' => 12,
                'id_tipo_usuario' => 2,
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            12 => 
            array (
                'id_usuario' => 13,
                'id_tipo_usuario' => 2,
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            13 => 
            array (
                'id_usuario' => 14,
                'id_tipo_usuario' => 1,
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            14 => 
            array (
                'id_usuario' => 2,
                'id_tipo_usuario' => 1,
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            15 => 
            array (
                'id_usuario' => 2,
                'id_tipo_usuario' => 3,
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            16 => 
            array (
                'id_usuario' => 2,
                'id_tipo_usuario' => 4,
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            17 => 
            array (
                'id_usuario' => 14,
                'id_tipo_usuario' => 2,
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            18 => 
            array (
                'id_usuario' => 14,
                'id_tipo_usuario' => 3,
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            19 => 
            array (
                'id_usuario' => 14,
                'id_tipo_usuario' => 4,
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            20 => 
            array (
                'id_usuario' => 11,
                'id_tipo_usuario' => 1,
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            21 => 
            array (
                'id_usuario' => 11,
                'id_tipo_usuario' => 3,
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            22 => 
            array (
                'id_usuario' => 11,
                'id_tipo_usuario' => 4,
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
        ));
        
        
    }
}