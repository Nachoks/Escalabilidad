<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class RegistrosTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('registros')->delete();
        
        \DB::table('registros')->insert(array (
            0 => 
            array (
                'id_registro_rendicion' => 1,
                'id_rendicion' => 1,
                'id_usuario_pagador' => 2,
                'fecha_pago' => '2026-02-09',
                'monto_pagado' => 142236,
                'nombre_original' => 'scaled_3fa5644f-97c5-40fc-b1d9-a8bd2119429f3245470489031184902.jpg',
                'nombre_fisico' => 'PAGO_1770667298.jpg',
                'ruta_relativa' => '001/pago/PAGO_1770667298.jpg',
                'peso_kb' => '1773.09',
                'extension' => 'jpg',
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
        ));
        
        
    }
}