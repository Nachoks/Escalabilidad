<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class HojasTiempoSemanasTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('hojas_tiempo_semanas')->delete();
        
        \DB::table('hojas_tiempo_semanas')->insert(array (
            0 => 
            array (
                'id_hoja_semana' => 8,
                'id_usuario' => 10,
                'id_servicio' => 151,
                'id_oc_cliente' => 170,
                'numero_hct' => 2,
                'nombre_comprobante' => '02-1-068-HTC-02',
                'centro_costo' => '02-1-068',
                'numero_semana' => 12,
                'observacion' => NULL,
                'fecha_inicio' => '2026-03-16',
                'fecha_fin' => '2026-03-22',
                'estado' => 'Aprobada',
                'validador_id' => 11,
                'created_at' => '2026-03-23 15:48:29',
                'updated_at' => '2026-03-23 18:03:08',
            ),
            1 => 
            array (
                'id_hoja_semana' => 11,
                'id_usuario' => 5,
                'id_servicio' => 151,
                'id_oc_cliente' => 170,
                'numero_hct' => 1,
                'nombre_comprobante' => '02-1-068-HTC-01',
                'centro_costo' => '02-1-068',
                'numero_semana' => 12,
                'observacion' => NULL,
                'fecha_inicio' => '2026-03-16',
                'fecha_fin' => '2026-03-22',
                'estado' => 'Aprobada',
                'validador_id' => 11,
                'created_at' => '2026-03-24 20:35:51',
                'updated_at' => '2026-03-25 13:54:42',
            ),
            2 => 
            array (
                'id_hoja_semana' => 12,
                'id_usuario' => 4,
                'id_servicio' => 120,
                'id_oc_cliente' => 141,
                'numero_hct' => 2,
                'nombre_comprobante' => '09-1-010-HTC-02',
                'centro_costo' => '09-1-010',
                'numero_semana' => 14,
                'observacion' => NULL,
                'fecha_inicio' => '2026-03-30',
                'fecha_fin' => '2026-04-05',
                'estado' => 'Aprobada',
                'validador_id' => 1,
                'created_at' => '2026-04-01 15:48:05',
                'updated_at' => '2026-04-02 20:37:00',
            ),
        ));
        
        
    }
}