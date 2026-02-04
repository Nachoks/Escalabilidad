<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class AreasEmpresaTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('areas_empresa')->delete();
        
        \DB::table('areas_empresa')->insert(array (
            0 => 
            array (
                'id_area' => 1,
                'id_empresa' => 1,
                'nombre_area' => 'Automatización',
                'codigo_area' => 1,
                'created_at' => '2026-02-03 19:34:09',
                'updated_at' => '2026-02-03 19:34:09',
            ),
        ));
        
        
    }
}