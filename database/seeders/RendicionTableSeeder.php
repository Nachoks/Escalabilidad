<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class RendicionTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('rendicion')->delete();
        
        \DB::table('rendicion')->insert(array (
            0 => 
            array (
                'id_rendicion' => 1,
                'fecha' => '2026-02-09',
                'proposito' => 'Terreno 02-02-2026 al 06-02-2026',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '01-1-020',
                'id_servicio' => 21,
                'id_usuario' => 4,
            ),
            1 => 
            array (
                'id_rendicion' => 2,
                'fecha' => NULL,
                'proposito' => 'Servicio en terreno',
                'monto_entregado' => 0,
                'estado' => 'Borrador',
                'centro_costo' => '02-1-061',
                'id_servicio' => 84,
                'id_usuario' => 11,
            ),
            2 => 
            array (
                'id_rendicion' => 3,
                'fecha' => '2026-02-10',
                'proposito' => 'Trabajo Softys',
                'monto_entregado' => 0,
                'estado' => 'Pendiente de Validación',
                'centro_costo' => '00-1-001',
                'id_servicio' => 148,
                'id_usuario' => 10,
            ),
            3 => 
            array (
                'id_rendicion' => 4,
                'fecha' => NULL,
                'proposito' => 'almuerzo',
                'monto_entregado' => 0,
                'estado' => 'Borrador',
                'centro_costo' => '00-1-001',
                'id_servicio' => 148,
                'id_usuario' => 2,
            ),
        ));
        
        
    }
}