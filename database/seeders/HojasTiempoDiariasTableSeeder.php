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
                'id_hoja_diaria' => 50,
                'id_hoja_semana' => 8,
                'fecha' => '2026-03-16',
                'lugar' => 'TERRENO',
                'area' => 'Talagante',
                'tipo_dia' => 'HABIL',
                'horario_inicio' => '08:00:00',
                'horario_fin' => '18:00:00',
                'viaje_horas' => 2.0,
                'estado' => 'Aprobada',
                'observacion' => NULL,
                'validador_id' => 11,
                'created_at' => '2026-03-23 15:48:29',
                'updated_at' => '2026-03-23 18:01:31',
            ),
            1 => 
            array (
                'id_hoja_diaria' => 51,
                'id_hoja_semana' => 8,
                'fecha' => '2026-03-17',
                'lugar' => 'TERRENO',
                'area' => 'Talagante',
                'tipo_dia' => 'HABIL',
                'horario_inicio' => '09:00:00',
                'horario_fin' => '18:00:00',
                'viaje_horas' => 0.0,
                'estado' => 'Aprobada',
                'observacion' => NULL,
                'validador_id' => 11,
                'created_at' => '2026-03-23 15:48:29',
                'updated_at' => '2026-03-23 18:01:24',
            ),
            2 => 
            array (
                'id_hoja_diaria' => 52,
                'id_hoja_semana' => 8,
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
                'created_at' => '2026-03-23 15:48:29',
                'updated_at' => '2026-03-23 18:01:55',
            ),
            3 => 
            array (
                'id_hoja_diaria' => 53,
                'id_hoja_semana' => 8,
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
                'created_at' => '2026-03-23 15:48:29',
                'updated_at' => '2026-03-23 18:02:00',
            ),
            4 => 
            array (
                'id_hoja_diaria' => 54,
                'id_hoja_semana' => 8,
                'fecha' => '2026-03-20',
                'lugar' => 'DESCANSO',
                'area' => NULL,
                'tipo_dia' => 'NO_HABIL',
                'horario_inicio' => NULL,
                'horario_fin' => NULL,
                'viaje_horas' => 0.0,
                'estado' => 'Aprobada',
                'observacion' => NULL,
                'validador_id' => 11,
                'created_at' => '2026-03-23 15:48:29',
                'updated_at' => '2026-03-23 18:02:09',
            ),
            5 => 
            array (
                'id_hoja_diaria' => 55,
                'id_hoja_semana' => 8,
                'fecha' => '2026-03-21',
                'lugar' => 'DESCANSO',
                'area' => NULL,
                'tipo_dia' => 'NO_HABIL',
                'horario_inicio' => NULL,
                'horario_fin' => NULL,
                'viaje_horas' => 0.0,
                'estado' => 'Aprobada',
                'observacion' => NULL,
                'validador_id' => 11,
                'created_at' => '2026-03-23 15:48:29',
                'updated_at' => '2026-03-23 18:02:15',
            ),
            6 => 
            array (
                'id_hoja_diaria' => 56,
                'id_hoja_semana' => 8,
                'fecha' => '2026-03-22',
                'lugar' => 'DESCANSO',
                'area' => NULL,
                'tipo_dia' => 'NO_HABIL',
                'horario_inicio' => NULL,
                'horario_fin' => NULL,
                'viaje_horas' => 0.0,
                'estado' => 'Aprobada',
                'observacion' => NULL,
                'validador_id' => 11,
                'created_at' => '2026-03-23 15:48:29',
                'updated_at' => '2026-03-23 18:02:20',
            ),
            7 => 
            array (
                'id_hoja_diaria' => 71,
                'id_hoja_semana' => 11,
                'fecha' => '2026-03-16',
                'lugar' => 'TERRENO',
                'area' => 'Talagante',
                'tipo_dia' => 'HABIL',
                'horario_inicio' => '08:00:00',
                'horario_fin' => '18:00:00',
                'viaje_horas' => 2.0,
                'estado' => 'Aprobada',
                'observacion' => NULL,
                'validador_id' => 11,
                'created_at' => '2026-03-24 20:35:51',
                'updated_at' => '2026-03-25 13:54:42',
            ),
            8 => 
            array (
                'id_hoja_diaria' => 72,
                'id_hoja_semana' => 11,
                'fecha' => '2026-03-17',
                'lugar' => 'TERRENO',
                'area' => 'Talagante',
                'tipo_dia' => 'HABIL',
                'horario_inicio' => '09:00:00',
                'horario_fin' => '18:00:00',
                'viaje_horas' => 0.0,
                'estado' => 'Aprobada',
                'observacion' => NULL,
                'validador_id' => 11,
                'created_at' => '2026-03-24 20:35:51',
                'updated_at' => '2026-03-25 13:54:42',
            ),
            9 => 
            array (
                'id_hoja_diaria' => 73,
                'id_hoja_semana' => 11,
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
                'created_at' => '2026-03-24 20:35:51',
                'updated_at' => '2026-03-25 13:54:42',
            ),
            10 => 
            array (
                'id_hoja_diaria' => 74,
                'id_hoja_semana' => 11,
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
                'created_at' => '2026-03-24 20:35:51',
                'updated_at' => '2026-03-25 13:54:42',
            ),
            11 => 
            array (
                'id_hoja_diaria' => 75,
                'id_hoja_semana' => 11,
                'fecha' => '2026-03-20',
                'lugar' => 'DESCANSO',
                'area' => NULL,
                'tipo_dia' => 'NO_HABIL',
                'horario_inicio' => NULL,
                'horario_fin' => NULL,
                'viaje_horas' => 0.0,
                'estado' => 'Aprobada',
                'observacion' => NULL,
                'validador_id' => 11,
                'created_at' => '2026-03-24 20:35:51',
                'updated_at' => '2026-03-25 13:54:42',
            ),
            12 => 
            array (
                'id_hoja_diaria' => 76,
                'id_hoja_semana' => 11,
                'fecha' => '2026-03-21',
                'lugar' => 'DESCANSO',
                'area' => NULL,
                'tipo_dia' => 'NO_HABIL',
                'horario_inicio' => NULL,
                'horario_fin' => NULL,
                'viaje_horas' => 0.0,
                'estado' => 'Aprobada',
                'observacion' => NULL,
                'validador_id' => 11,
                'created_at' => '2026-03-24 20:35:51',
                'updated_at' => '2026-03-25 13:54:42',
            ),
            13 => 
            array (
                'id_hoja_diaria' => 77,
                'id_hoja_semana' => 11,
                'fecha' => '2026-03-22',
                'lugar' => 'DESCANSO',
                'area' => NULL,
                'tipo_dia' => 'NO_HABIL',
                'horario_inicio' => NULL,
                'horario_fin' => NULL,
                'viaje_horas' => 0.0,
                'estado' => 'Aprobada',
                'observacion' => NULL,
                'validador_id' => 11,
                'created_at' => '2026-03-24 20:35:51',
                'updated_at' => '2026-03-25 13:54:42',
            ),
        ));
        
        
    }
}