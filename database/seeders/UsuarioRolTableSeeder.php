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
        ));
        
        
    }
}