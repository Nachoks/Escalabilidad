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
            3 => 
            array (
                'id_hoja_semana' => 14,
                'id_usuario' => 4,
                'id_servicio' => 120,
                'id_oc_cliente' => 141,
                'numero_hct' => 3,
                'nombre_comprobante' => '09-1-010-HTC-03',
                'centro_costo' => '09-1-010',
                'numero_semana' => 15,
                'observacion' => NULL,
                'fecha_inicio' => '2026-04-06',
                'fecha_fin' => '2026-04-12',
                'estado' => 'Aprobada',
                'validador_id' => 1,
                'created_at' => '2026-04-07 13:00:37',
                'updated_at' => '2026-04-14 13:54:30',
            ),
            4 => 
            array (
                'id_hoja_semana' => 15,
                'id_usuario' => 14,
                'id_servicio' => 100,
                'id_oc_cliente' => 114,
                'numero_hct' => 20,
                'nombre_comprobante' => '04-1-001-HTC-20',
                'centro_costo' => '04-1-001',
                'numero_semana' => 16,
                'observacion' => NULL,
                'fecha_inicio' => '2026-04-13',
                'fecha_fin' => '2026-04-19',
                'estado' => 'Borrador',
                'validador_id' => NULL,
                'created_at' => '2026-04-09 19:37:46',
                'updated_at' => '2026-04-09 19:37:46',
            ),
            5 => 
            array (
                'id_hoja_semana' => 16,
                'id_usuario' => 9,
                'id_servicio' => 98,
                'id_oc_cliente' => 111,
                'numero_hct' => 1,
                'nombre_comprobante' => '03-1-010-HTC-01',
                'centro_costo' => '03-1-010',
                'numero_semana' => 15,
                'observacion' => NULL,
                'fecha_inicio' => '2026-04-06',
                'fecha_fin' => '2026-04-12',
                'estado' => 'Aprobada',
                'validador_id' => 1,
                'created_at' => '2026-04-14 14:46:54',
                'updated_at' => '2026-04-16 15:03:27',
            ),
            6 => 
            array (
                'id_hoja_semana' => 17,
                'id_usuario' => 9,
                'id_servicio' => 98,
                'id_oc_cliente' => 111,
                'numero_hct' => 2,
                'nombre_comprobante' => '03-1-010-HTC-02',
                'centro_costo' => '03-1-010',
                'numero_semana' => 16,
                'observacion' => NULL,
                'fecha_inicio' => '2026-04-13',
                'fecha_fin' => '2026-04-19',
                'estado' => 'Aprobada',
                'validador_id' => 1,
                'created_at' => '2026-04-16 20:57:43',
                'updated_at' => '2026-04-16 21:11:32',
            ),
            7 => 
            array (
                'id_hoja_semana' => 18,
                'id_usuario' => 11,
                'id_servicio' => 153,
                'id_oc_cliente' => 172,
                'numero_hct' => 1,
                'nombre_comprobante' => '02-1-070-HTC-01',
                'centro_costo' => '02-1-070',
                'numero_semana' => 16,
                'observacion' => 'Corresponde a los servicios de tendido de cableado ethernet',
                'fecha_inicio' => '2026-04-13',
                'fecha_fin' => '2026-04-19',
                'estado' => 'Enviada',
                'validador_id' => NULL,
                'created_at' => '2026-04-20 19:22:01',
                'updated_at' => '2026-04-21 00:07:14',
            ),
            8 => 
            array (
                'id_hoja_semana' => 19,
                'id_usuario' => 10,
                'id_servicio' => 153,
                'id_oc_cliente' => 172,
                'numero_hct' => 5,
                'nombre_comprobante' => '02-1-070-HTC-05',
                'centro_costo' => '02-1-070',
                'numero_semana' => 16,
                'observacion' => NULL,
                'fecha_inicio' => '2026-04-13',
                'fecha_fin' => '2026-04-19',
                'estado' => 'Borrador',
                'validador_id' => NULL,
                'created_at' => '2026-04-20 20:08:48',
                'updated_at' => '2026-04-20 20:08:48',
            ),
            9 => 
            array (
                'id_hoja_semana' => 20,
                'id_usuario' => 5,
                'id_servicio' => 153,
                'id_oc_cliente' => 173,
                'numero_hct' => 7,
                'nombre_comprobante' => '02-1-070-HTC-07',
                'centro_costo' => '02-1-070',
                'numero_semana' => 16,
                'observacion' => NULL,
                'fecha_inicio' => '2026-04-13',
                'fecha_fin' => '2026-04-19',
                'estado' => 'Borrador',
                'validador_id' => NULL,
                'created_at' => '2026-04-20 20:11:53',
                'updated_at' => '2026-04-20 20:11:53',
            ),
            10 => 
            array (
                'id_hoja_semana' => 21,
                'id_usuario' => 5,
                'id_servicio' => 153,
                'id_oc_cliente' => 172,
                'numero_hct' => 4,
                'nombre_comprobante' => '02-1-070-HTC-04',
                'centro_costo' => '02-1-070',
                'numero_semana' => 16,
                'observacion' => NULL,
                'fecha_inicio' => '2026-04-13',
                'fecha_fin' => '2026-04-19',
                'estado' => 'Borrador',
                'validador_id' => NULL,
                'created_at' => '2026-04-20 20:15:14',
                'updated_at' => '2026-04-20 20:15:14',
            ),
        ));
        
        
    }
}