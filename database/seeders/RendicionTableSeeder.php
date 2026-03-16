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
                'fecha' => '2026-02-12',
                'proposito' => 'Servicio en terreno',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
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
                'estado' => 'Pagada',
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
            4 => 
            array (
                'id_rendicion' => 5,
                'fecha' => '2026-02-11',
                'proposito' => 'Terreno MCEN',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '01-1-016',
                'id_servicio' => 17,
                'id_usuario' => 8,
            ),
            5 => 
            array (
                'id_rendicion' => 6,
                'fecha' => '2026-02-12',
                'proposito' => 'Asado',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '00-1-001',
                'id_servicio' => 148,
                'id_usuario' => 1,
            ),
            6 => 
            array (
                'id_rendicion' => 7,
                'fecha' => '2026-02-26',
                'proposito' => 'Gastos Varios',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '00-1-001',
                'id_servicio' => 148,
                'id_usuario' => 11,
            ),
            7 => 
            array (
                'id_rendicion' => 8,
                'fecha' => '2026-02-15',
                'proposito' => 'Terreno en MCEN',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '01-1-016',
                'id_servicio' => 17,
                'id_usuario' => 8,
            ),
            8 => 
            array (
                'id_rendicion' => 9,
                'fecha' => '2026-02-24',
                'proposito' => 'MCEN Terreno',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '01-1-016',
                'id_servicio' => 17,
                'id_usuario' => 8,
            ),
            9 => 
            array (
                'id_rendicion' => 10,
                'fecha' => '2026-02-24',
                'proposito' => 'DRR',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '01-1-016',
                'id_servicio' => 17,
                'id_usuario' => 12,
            ),
            10 => 
            array (
                'id_rendicion' => 12,
                'fecha' => '2026-02-26',
                'proposito' => 'Compra de equipos',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '01-1-016',
                'id_servicio' => 17,
                'id_usuario' => 14,
            ),
            11 => 
            array (
                'id_rendicion' => 13,
                'fecha' => NULL,
                'proposito' => 'Prueba2',
                'monto_entregado' => 0,
                'estado' => 'Borrador',
                'centro_costo' => '06-1-001',
                'id_servicio' => 105,
                'id_usuario' => 14,
            ),
            12 => 
            array (
                'id_rendicion' => 14,
                'fecha' => '2026-02-27',
                'proposito' => 'Gasto por encomienda',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '00-1-001',
                'id_servicio' => 148,
                'id_usuario' => 10,
            ),
            13 => 
            array (
                'id_rendicion' => 15,
                'fecha' => '2026-03-02',
                'proposito' => 'TERRENO MCEN',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '01-1-016',
                'id_servicio' => 17,
                'id_usuario' => 8,
            ),
            14 => 
            array (
                'id_rendicion' => 16,
                'fecha' => '2026-03-10',
                'proposito' => 'Turno MCEN',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '01-1-017',
                'id_servicio' => 18,
                'id_usuario' => 5,
            ),
            15 => 
            array (
                'id_rendicion' => 17,
                'fecha' => '2026-03-09',
                'proposito' => 'viaje a los loros',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '09-1-010',
                'id_servicio' => 120,
                'id_usuario' => 4,
            ),
            16 => 
            array (
                'id_rendicion' => 18,
                'fecha' => NULL,
                'proposito' => 'Varios',
                'monto_entregado' => 0,
                'estado' => 'Borrador',
                'centro_costo' => '00-1-001',
                'id_servicio' => 148,
                'id_usuario' => 11,
            ),
            17 => 
            array (
                'id_rendicion' => 19,
                'fecha' => '2026-03-09',
                'proposito' => 'suministros mantención gabinetes',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '02-1-068',
                'id_servicio' => 151,
                'id_usuario' => 10,
            ),
            18 => 
            array (
                'id_rendicion' => 20,
                'fecha' => '2026-03-09',
                'proposito' => 'Abono estadía mantención Softys COG',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '02-1-068',
                'id_servicio' => 151,
                'id_usuario' => 10,
            ),
            19 => 
            array (
                'id_rendicion' => 21,
                'fecha' => '2026-03-11',
                'proposito' => 'Terreno semana 6 y 8',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '01-1-016',
                'id_servicio' => 17,
                'id_usuario' => 7,
            ),
            20 => 
            array (
                'id_rendicion' => 22,
                'fecha' => '2026-03-12',
                'proposito' => 'Traslados',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '09-1-010',
                'id_servicio' => 120,
                'id_usuario' => 2,
            ),
            21 => 
            array (
                'id_rendicion' => 23,
                'fecha' => '2026-03-12',
                'proposito' => 'Asado de cumpleaños y bienvenida',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '00-1-001',
                'id_servicio' => 148,
                'id_usuario' => 1,
            ),
        ));
        
        
    }
}