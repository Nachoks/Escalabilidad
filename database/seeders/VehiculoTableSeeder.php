<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class VehiculoTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('vehiculo')->delete();
        
        \DB::table('vehiculo')->insert(array (
            0 => 
            array (
                'id' => 1,
                'patente' => 'TXYH73',
                'disponibilidad' => 'Disponible',
                'id_empresa' => 1,
                'created_at' => '2026-02-03 19:34:13',
                'updated_at' => '2026-02-03 19:34:13',
            ),
        ));
        
        
    }
}