<?php


namespace Database\Seeders;


use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;


class HojasTiempoActividadesTableSeeder extends Seeder
{
    public function run()
    {
        DB::table('hojas_tiempo_actividades')->delete();
       
        DB::table('hojas_tiempo_actividades')->insert([
            // --- ACTIVIDADES SEMANA 6 ---
            // Día 16 Marzo: 08 a 18 (10 hrs) - 2 hrs viaje = 8 hrs netas
            [
                'id_actividad' => 1,
                'id_hoja_diaria' => 36,
                'hora_inicio' => '10:00:00',
                'hora_fin' => '18:00:00',
                'descripcion' => 'Trabajo en terreno Talagante',
                'horas_habiles' => 8.0,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-17 20:31:57',
                'updated_at' => '2026-03-17 20:31:57',
            ],
            // Día 17 Marzo: 08 a 18 (10 hrs) - 0 hrs viaje = 10 hrs netas
            [
                'id_actividad' => 2,
                'id_hoja_diaria' => 37,
                'hora_inicio' => '08:00:00',
                'hora_fin' => '18:00:00',
                'descripcion' => 'Instalación y montaje',
                'horas_habiles' => 10.0,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-17 20:31:57',
                'updated_at' => '2026-03-17 20:31:57',
            ],
            // Día 18 Marzo: 09 a 18 (9 hrs) - 0 hrs viaje = 9 hrs netas
            [
                'id_actividad' => 3,
                'id_hoja_diaria' => 38,
                'hora_inicio' => '09:00:00',
                'hora_fin' => '18:00:00',
                'descripcion' => 'Configuración de equipos',
                'horas_habiles' => 9.0,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-18 20:31:57',
                'updated_at' => '2026-03-18 20:31:57',
            ],
            // Día 19 Marzo: 09 a 18 (9 hrs) - 4 hrs viaje = 5 hrs netas
            [
                'id_actividad' => 4,
                'id_hoja_diaria' => 39,
                'hora_inicio' => '13:00:00',
                'hora_fin' => '18:00:00',
                'descripcion' => 'Pruebas finales y retorno',
                'horas_habiles' => 5.0,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-19 20:31:57',
                'updated_at' => '2026-03-19 20:31:57',
            ],
           
            // --- ACTIVIDADES SEMANA 7 ---
            // Día 16 Marzo: 08 a 18 (10 hrs) - 2 hrs viaje = 8 hrs netas
            [
                'id_actividad' => 5,
                'id_hoja_diaria' => 43,
                'hora_inicio' => '10:00:00',
                'hora_fin' => '18:00:00',
                'descripcion' => 'Apoyo en terreno Talagante',
                'horas_habiles' => 8.0,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-17 21:08:59',
                'updated_at' => '2026-03-17 21:08:59',
            ],
            // Día 17 Marzo: 08 a 18 (10 hrs) - 0 hrs viaje = 10 hrs netas
            [
                'id_actividad' => 6,
                'id_hoja_diaria' => 44,
                'hora_inicio' => '08:00:00',
                'hora_fin' => '18:00:00',
                'descripcion' => 'Tendido de red estructurada',
                'horas_habiles' => 10.0,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-17 21:08:59',
                'updated_at' => '2026-03-17 21:08:59',
            ],
            // Día 18 Marzo: 09 a 18 (9 hrs) - 0 hrs viaje = 9 hrs netas
            [
                'id_actividad' => 7,
                'id_hoja_diaria' => 45,
                'hora_inicio' => '09:00:00',
                'hora_fin' => '18:00:00',
                'descripcion' => 'Pruebas de conectividad',
                'horas_habiles' => 9.0,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-18 21:08:59',
                'updated_at' => '2026-03-18 21:08:59',
            ],
            // Día 19 Marzo: 09 a 18 (9 hrs) - 3 hrs viaje = 6 hrs netas
            [
                'id_actividad' => 8,
                'id_hoja_diaria' => 46,
                'hora_inicio' => '12:00:00',
                'hora_fin' => '18:00:00',
                'descripcion' => 'Entrega final y validación de cliente',
                'horas_habiles' => 6.0,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-19 21:08:59',
                'updated_at' => '2026-03-19 21:08:59',
            ],
        ]);
    }
}

