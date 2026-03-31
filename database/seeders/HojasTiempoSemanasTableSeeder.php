<?php


namespace Database\Seeders;


use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;


class HojasTiempoSemanasTableSeeder extends Seeder
{
    public function run()
    {
        DB::table('hojas_tiempo_semanas')->delete();
       
        DB::table('hojas_tiempo_semanas')->insert([
            [
                'id_hoja_semana' => 6,
                'id_usuario' => 5, // ID de usuario genérico (puedes cambiarlo si recuerdas el real)
                'id_servicio' => 1,
                'id_oc_cliente' => 1,
                'numero_hct' => 1,
                'nombre_comprobante' => 'TALAGANTE-HTC-01',
                'centro_costo' => 'Talagante',
                'numero_semana' => 12,
                'fecha_inicio' => '2026-03-16',
                'fecha_fin' => '2026-03-22',
                'estado' => 'Enviada',
                'observacion' => null,
                'validador_id' => 11, // El ID 11 fue quien aprobó los días
                'created_at' => '2026-03-17 20:30:00',
                'updated_at' => '2026-03-20 17:46:15',
            ],
            [
                'id_hoja_semana' => 7,
                'id_usuario' => 10, // Segundo usuario genérico
                'id_servicio' => 1,
                'id_oc_cliente' => 1,
                'numero_hct' => 2,
                'nombre_comprobante' => 'TALAGANTE-HTC-02',
                'centro_costo' => 'Talagante',
                'numero_semana' => 12,
                'fecha_inicio' => '2026-03-16',
                'fecha_fin' => '2026-03-22',
                'estado' => 'Enviada',
                'observacion' => null,
                'validador_id' => 11,
                'created_at' => '2026-03-17 21:08:00',
                'updated_at' => '2026-03-20 17:46:01',
            ]
        ]);
    }
}
