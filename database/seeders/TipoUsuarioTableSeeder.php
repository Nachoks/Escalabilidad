<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class TipoUsuarioTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('tipo_usuario')->delete();
        
        \DB::table('tipo_usuario')->insert(array (
            0 => 
            array (
                'id_tipo_usuario' => 1,
                'tipo_usuario' => 'Administrador',
                'created_at' => '2026-02-03 19:34:09',
                'updated_at' => '2026-03-11 16:46:15',
            ),
            1 => 
            array (
                'id_tipo_usuario' => 2,
                'tipo_usuario' => 'Conductor',
                'created_at' => '2026-02-03 19:34:09',
                'updated_at' => '2026-03-11 16:46:15',
            ),
            2 => 
            array (
                'id_tipo_usuario' => 3,
                'tipo_usuario' => 'Validador',
                'created_at' => '2026-02-03 19:34:09',
                'updated_at' => '2026-03-11 16:46:15',
            ),
            3 => 
            array (
                'id_tipo_usuario' => 4,
                'tipo_usuario' => 'Usuario',
                'created_at' => '2026-02-03 19:34:09',
                'updated_at' => '2026-03-11 16:46:15',
            ),
            4 => 
            array (
                'id_tipo_usuario' => 5,
                'tipo_usuario' => 'Validador HT',
                'created_at' => '2026-02-03 19:34:09',
                'updated_at' => '2026-03-11 16:46:15',
            ),
        ));
        
        
    }
}