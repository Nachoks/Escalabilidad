<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class HojasTiempoDiariasTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('hojas_tiempo_diarias')->delete();
        
        \DB::table('hojas_tiempo_diarias')->insert(array (
            0 => 
            array (
                'id_hoja_diaria' => 36,
                'id_hoja_semana' => 6,
                'fecha' => '2026-03-16',
                'lugar' => 'TERRENO',
                'area' => 'Talagante',
                'tipo_dia' => 'HABIL',
                'horario_inicio' => '08:00:00',
                'horario_fin' => '18:00:00',
                'viaje_horas' => 2.0,
                'estado' => 'Enviada',
                'observacion' => NULL,
                'validador_id' => NULL,
                'created_at' => '2026-03-17 20:31:57',
                'updated_at' => '2026-03-20 17:46:15',
            ),
            1 => 
            array (
                'id_hoja_diaria' => 37,
                'id_hoja_semana' => 6,
                'fecha' => '2026-03-17',
                'lugar' => 'TERRENO',
                'area' => 'Talagante',
                'tipo_dia' => 'HABIL',
                'horario_inicio' => '08:00:00',
                'horario_fin' => '18:00:00',
                'viaje_horas' => 0.0,
                'estado' => 'Aprobada',
                'observacion' => NULL,
                'validador_id' => 11,
                'created_at' => '2026-03-17 20:31:57',
                'updated_at' => '2026-03-17 21:42:36',
            ),
            2 => 
            array (
                'id_hoja_diaria' => 38,
                'id_hoja_semana' => 6,
                'fecha' => '2026-03-18',
                'lugar' => 'TERRENO',
                'area' => 'Talagante',
                'tipo_dia' => 'HABIL',
                'horario_inicio' => '09:00:00',
                'horario_fin' => '18:00:00',
                'viaje_horas' => 0.0,
                'estado' => 'Aprobada',
                'observacion' => NULL,
                'validador_id' => 11,
                'created_at' => '2026-03-17 20:31:57',
                'updated_at' => '2026-03-18 21:42:23',
            ),
            3 => 
            array (
                'id_hoja_diaria' => 39,
                'id_hoja_semana' => 6,
                'fecha' => '2026-03-19',
                'lugar' => 'TERRENO',
                'area' => 'Talagante',
                'tipo_dia' => 'HABIL',
                'horario_inicio' => '09:00:00',
                'horario_fin' => '18:00:00',
                'viaje_horas' => 4.0,
                'estado' => 'Aprobada',
                'observacion' => NULL,
                'validador_id' => 11,
                'created_at' => '2026-03-17 20:31:57',
                'updated_at' => '2026-03-20 17:14:21',
            ),
            4 => 
            array (
                'id_hoja_diaria' => 40,
                'id_hoja_semana' => 6,
                'fecha' => '2026-03-20',
                'lugar' => 'DESCANSO',
                'area' => NULL,
                'tipo_dia' => 'NO_HABIL',
                'horario_inicio' => NULL,
                'horario_fin' => NULL,
                'viaje_horas' => 0.0,
                'estado' => 'Enviada',
                'observacion' => NULL,
                'validador_id' => NULL,
                'created_at' => '2026-03-17 20:31:57',
                'updated_at' => '2026-03-20 17:46:15',
            ),
            5 => 
            array (
                'id_hoja_diaria' => 41,
                'id_hoja_semana' => 6,
                'fecha' => '2026-03-21',
                'lugar' => 'DESCANSO',
                'area' => NULL,
                'tipo_dia' => 'NO_HABIL',
                'horario_inicio' => NULL,
                'horario_fin' => NULL,
                'viaje_horas' => 0.0,
                'estado' => 'Enviada',
                'observacion' => NULL,
                'validador_id' => NULL,
                'created_at' => '2026-03-17 20:31:57',
                'updated_at' => '2026-03-20 17:46:15',
            ),
            6 => 
            array (
                'id_hoja_diaria' => 42,
                'id_hoja_semana' => 6,
                'fecha' => '2026-03-22',
                'lugar' => 'DESCANSO',
                'area' => NULL,
                'tipo_dia' => 'NO_HABIL',
                'horario_inicio' => NULL,
                'horario_fin' => NULL,
                'viaje_horas' => 0.0,
                'estado' => 'Enviada',
                'observacion' => NULL,
                'validador_id' => NULL,
                'created_at' => '2026-03-17 20:31:57',
                'updated_at' => '2026-03-20 17:46:15',
            ),
            7 => 
            array (
                'id_hoja_diaria' => 43,
                'id_hoja_semana' => 7,
                'fecha' => '2026-03-16',
                'lugar' => 'TERRENO',
                'area' => 'Talagante',
                'tipo_dia' => 'HABIL',
                'horario_inicio' => '08:00:00',
                'horario_fin' => '18:00:00',
                'viaje_horas' => 2.0,
                'estado' => 'Enviada',
                'observacion' => NULL,
                'validador_id' => NULL,
                'created_at' => '2026-03-17 21:08:59',
                'updated_at' => '2026-03-20 17:46:01',
            ),
            8 => 
            array (
                'id_hoja_diaria' => 44,
                'id_hoja_semana' => 7,
                'fecha' => '2026-03-17',
                'lugar' => 'TERRENO',
                'area' => 'Talagante',
                'tipo_dia' => 'HABIL',
                'horario_inicio' => '08:00:00',
                'horario_fin' => '18:00:00',
                'viaje_horas' => 0.0,
                'estado' => 'Aprobada',
                'observacion' => NULL,
                'validador_id' => 11,
                'created_at' => '2026-03-17 21:08:59',
                'updated_at' => '2026-03-17 21:42:54',
            ),
            9 => 
            array (
                'id_hoja_diaria' => 45,
                'id_hoja_semana' => 7,
                'fecha' => '2026-03-18',
                'lugar' => 'TERRENO',
                'area' => 'Talagante',
                'tipo_dia' => 'HABIL',
                'horario_inicio' => '09:00:00',
                'horario_fin' => '18:00:00',
                'viaje_horas' => 0.0,
                'estado' => 'Aprobada',
                'observacion' => NULL,
                'validador_id' => 11,
                'created_at' => '2026-03-17 21:08:59',
                'updated_at' => '2026-03-18 21:42:38',
            ),
            10 => 
            array (
                'id_hoja_diaria' => 46,
                'id_hoja_semana' => 7,
                'fecha' => '2026-03-19',
                'lugar' => 'TERRENO',
                'area' => 'Talagante',
                'tipo_dia' => 'HABIL',
                'horario_inicio' => '09:00:00',
                'horario_fin' => '18:00:00',
                'viaje_horas' => 3.0,
                'estado' => 'Aprobada',
                'observacion' => NULL,
                'validador_id' => 11,
                'created_at' => '2026-03-17 21:08:59',
                'updated_at' => '2026-03-20 17:14:27',
            ),
            11 => 
            array (
                'id_hoja_diaria' => 47,
                'id_hoja_semana' => 7,
                'fecha' => '2026-03-20',
                'lugar' => 'DESCANSO',
                'area' => NULL,
                'tipo_dia' => 'NO_HABIL',
                'horario_inicio' => NULL,
                'horario_fin' => NULL,
                'viaje_horas' => 0.0,
                'estado' => 'Enviada',
                'observacion' => NULL,
                'validador_id' => NULL,
                'created_at' => '2026-03-17 21:08:59',
                'updated_at' => '2026-03-20 17:46:18',
            ),
            12 => 
            array (
                'id_hoja_diaria' => 48,
                'id_hoja_semana' => 7,
                'fecha' => '2026-03-21',
                'lugar' => 'DESCANSO',
                'area' => NULL,
                'tipo_dia' => 'NO_HABIL',
                'horario_inicio' => NULL,
                'horario_fin' => NULL,
                'viaje_horas' => 0.0,
                'estado' => 'Enviada',
                'observacion' => NULL,
                'validador_id' => NULL,
                'created_at' => '2026-03-17 21:08:59',
                'updated_at' => '2026-03-20 17:46:18',
            ),
            13 => 
            array (
                'id_hoja_diaria' => 49,
                'id_hoja_semana' => 7,
                'fecha' => '2026-03-22',
                'lugar' => 'DESCANSO',
                'area' => NULL,
                'tipo_dia' => 'NO_HABIL',
                'horario_inicio' => NULL,
                'horario_fin' => NULL,
                'viaje_horas' => 0.0,
                'estado' => 'Enviada',
                'observacion' => NULL,
                'validador_id' => NULL,
                'created_at' => '2026-03-17 21:08:59',
                'updated_at' => '2026-03-20 17:46:18',
            ),
        ));
        
        
    }
}