<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class EmpresaTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('empresa')->delete();
        
        \DB::table('empresa')->insert(array (
            0 => 
            array (
                'id_empresa' => 1,
                'nombre_empresa' => 'Arenas y Arenas',
                'rol_empresa' => 'Matriz',
                'created_at' => '2026-02-03 19:34:09',
                'updated_at' => '2026-02-03 19:34:09',
            ),
        ));
        
        
    }
}