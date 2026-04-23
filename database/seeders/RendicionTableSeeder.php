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
                'fecha' => '2026-03-28',
                'proposito' => 'Materiales Gab. Com. Oficina IAA + Botequin',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
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
            22 => 
            array (
                'id_rendicion' => 24,
                'fecha' => '2026-03-23',
                'proposito' => 'Alojamiento Softys TA Cog',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '02-1-068',
                'id_servicio' => 151,
                'id_usuario' => 10,
            ),
            23 => 
            array (
                'id_rendicion' => 25,
                'fecha' => NULL,
                'proposito' => 'Mantención cogeneración',
                'monto_entregado' => 0,
                'estado' => 'Borrador',
                'centro_costo' => '02-1-068',
                'id_servicio' => 151,
                'id_usuario' => 5,
            ),
            24 => 
            array (
                'id_rendicion' => 26,
                'fecha' => '2026-03-25',
                'proposito' => 'gastos norte',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '01-1-016',
                'id_servicio' => 17,
                'id_usuario' => 12,
            ),
            25 => 
            array (
                'id_rendicion' => 27,
                'fecha' => '2026-03-27',
                'proposito' => 'Viaje Levantamiento Red OT',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '02-1-069',
                'id_servicio' => 152,
                'id_usuario' => 11,
            ),
            26 => 
            array (
                'id_rendicion' => 28,
                'fecha' => '2026-03-27',
            'proposito' => 'Cumpleaños SC (Rend. #24 ya pagada)',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '00-1-001',
                'id_servicio' => 148,
                'id_usuario' => 11,
            ),
            27 => 
            array (
                'id_rendicion' => 29,
                'fecha' => '2026-03-27',
            'proposito' => 'Mantención Cogeneración (Rend. #25 ya pagada)',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '02-1-068',
                'id_servicio' => 151,
                'id_usuario' => 11,
            ),
            28 => 
            array (
                'id_rendicion' => 30,
                'fecha' => '2026-03-27',
            'proposito' => 'Auditoria Interna 2026 (Rend. #26 ya pagada)',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '00-1-001',
                'id_servicio' => 148,
                'id_usuario' => 11,
            ),
            29 => 
            array (
                'id_rendicion' => 31,
                'fecha' => '2026-04-07',
                'proposito' => 'Cena PZ',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '00-1-001',
                'id_servicio' => 148,
                'id_usuario' => 11,
            ),
            30 => 
            array (
                'id_rendicion' => 32,
                'fecha' => NULL,
                'proposito' => 'combustible',
                'monto_entregado' => 0,
                'estado' => 'Borrador',
                'centro_costo' => '02-1-069',
                'id_servicio' => 152,
                'id_usuario' => 2,
            ),
            31 => 
            array (
                'id_rendicion' => 33,
                'fecha' => '2026-04-07',
                'proposito' => 'Viaje Levantamiento N°2',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '02-1-069',
                'id_servicio' => 152,
                'id_usuario' => 11,
            ),
            32 => 
            array (
                'id_rendicion' => 34,
                'fecha' => '2026-04-08',
                'proposito' => 'Retiro vasos IAA',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '00-1-001',
                'id_servicio' => 148,
                'id_usuario' => 9,
            ),
            33 => 
            array (
                'id_rendicion' => 35,
                'fecha' => '2026-04-09',
                'proposito' => 'MCEN Terreno',
                'monto_entregado' => 150000,
                'estado' => 'Pagada',
                'centro_costo' => '01-1-016',
                'id_servicio' => 17,
                'id_usuario' => 8,
            ),
            34 => 
            array (
                'id_rendicion' => 36,
                'fecha' => '2026-04-17',
                'proposito' => 'Operador Alza-Hombre',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '02-1-070',
                'id_servicio' => 153,
                'id_usuario' => 11,
            ),
            35 => 
            array (
                'id_rendicion' => 37,
                'fecha' => '2026-04-13',
                'proposito' => 'Tester de Red',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '02-1-070',
                'id_servicio' => 153,
                'id_usuario' => 11,
            ),
            36 => 
            array (
                'id_rendicion' => 39,
                'fecha' => '2026-04-20',
                'proposito' => 'Servicio en terreno',
                'monto_entregado' => 0,
                'estado' => 'Aprobada',
                'centro_costo' => '02-1-070',
                'id_servicio' => 153,
                'id_usuario' => 11,
            ),
            37 => 
            array (
                'id_rendicion' => 40,
                'fecha' => '2026-04-16',
                'proposito' => 'Hospedaje Santiago Workshop ABB',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '00-1-001',
                'id_servicio' => 148,
                'id_usuario' => 11,
            ),
            38 => 
            array (
                'id_rendicion' => 41,
                'fecha' => '2026-04-17',
                'proposito' => 'Limpieza de servidores',
                'monto_entregado' => 0,
                'estado' => 'Pagada',
                'centro_costo' => '02-1-070',
                'id_servicio' => 153,
                'id_usuario' => 5,
            ),
            39 => 
            array (
                'id_rendicion' => 42,
                'fecha' => '2026-04-17',
                'proposito' => 'Comida',
                'monto_entregado' => 0,
                'estado' => 'Observada',
                'centro_costo' => '00-1-001',
                'id_servicio' => 148,
                'id_usuario' => 9,
            ),
        ));
        
        
    }
}