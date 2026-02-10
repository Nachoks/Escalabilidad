<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class GastoTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('gasto')->delete();
        
        \DB::table('gasto')->insert(array (
            0 => 
            array (
                'id_gasto' => 1,
                'fecha' => '2026-02-09',
                'num_documento' => '89538593',
                'monto' => 7900,
                'estado_gasto' => 'Aprobado',
                'comentario_validador' => NULL,
                'tipo_documento' => 'Boleta',
                'detalle' => 'Alimentación',
                'id_rendicion' => 1,
                'id_validador' => 2,
            ),
            1 => 
            array (
                'id_gasto' => 2,
                'fecha' => '2026-02-09',
                'num_documento' => '341503',
                'monto' => 14880,
                'estado_gasto' => 'Aprobado',
                'comentario_validador' => NULL,
                'tipo_documento' => 'Boleta',
                'detalle' => 'Alimentación',
                'id_rendicion' => 1,
                'id_validador' => 2,
            ),
            2 => 
            array (
                'id_gasto' => 3,
                'fecha' => '2026-02-09',
                'num_documento' => '341809',
                'monto' => 21980,
                'estado_gasto' => 'Aprobado',
                'comentario_validador' => NULL,
                'tipo_documento' => 'Boleta',
                'detalle' => 'Alimentación',
                'id_rendicion' => 1,
                'id_validador' => 2,
            ),
            3 => 
            array (
                'id_gasto' => 4,
                'fecha' => '2026-02-09',
                'num_documento' => '342080',
                'monto' => 21980,
                'estado_gasto' => 'Aprobado',
                'comentario_validador' => NULL,
                'tipo_documento' => 'Boleta',
                'detalle' => 'Alimentación',
                'id_rendicion' => 1,
                'id_validador' => 2,
            ),
            4 => 
            array (
                'id_gasto' => 5,
                'fecha' => '2026-02-09',
                'num_documento' => '96488',
                'monto' => 1300,
                'estado_gasto' => 'Aprobado',
                'comentario_validador' => NULL,
                'tipo_documento' => 'Boleta',
                'detalle' => 'Alimentación',
                'id_rendicion' => 1,
                'id_validador' => 2,
            ),
            5 => 
            array (
                'id_gasto' => 6,
                'fecha' => '2026-02-09',
                'num_documento' => '41010',
                'monto' => 61490,
                'estado_gasto' => 'Aprobado',
                'comentario_validador' => NULL,
                'tipo_documento' => 'Boleta',
                'detalle' => 'Alimentación',
                'id_rendicion' => 1,
                'id_validador' => 2,
            ),
            6 => 
            array (
                'id_gasto' => 7,
                'fecha' => '2026-02-09',
                'num_documento' => '17700342587',
                'monto' => 2590,
                'estado_gasto' => 'Aprobado',
                'comentario_validador' => NULL,
                'tipo_documento' => 'Boleta',
                'detalle' => 'Alimentación',
                'id_rendicion' => 1,
                'id_validador' => 2,
            ),
            7 => 
            array (
                'id_gasto' => 8,
                'fecha' => '2026-02-09',
                'num_documento' => NULL,
                'monto' => 5137,
                'estado_gasto' => 'Aprobado',
                'comentario_validador' => NULL,
                'tipo_documento' => 'Boleta',
                'detalle' => 'Transporte',
                'id_rendicion' => 1,
                'id_validador' => 2,
            ),
            8 => 
            array (
                'id_gasto' => 9,
                'fecha' => '2026-02-09',
                'num_documento' => NULL,
                'monto' => 4979,
                'estado_gasto' => 'Aprobado',
                'comentario_validador' => NULL,
                'tipo_documento' => 'Boleta',
                'detalle' => 'Transporte',
                'id_rendicion' => 1,
                'id_validador' => 2,
            ),
            9 => 
            array (
                'id_gasto' => 11,
                'fecha' => '2025-10-30',
                'num_documento' => NULL,
                'monto' => 10000,
                'estado_gasto' => 'Pendiente',
                'comentario_validador' => NULL,
                'tipo_documento' => 'Comprobante de Transferencia',
                'detalle' => 'Alojamiento',
                'id_rendicion' => 2,
                'id_validador' => NULL,
            ),
            10 => 
            array (
                'id_gasto' => 12,
                'fecha' => '2026-02-03',
                'num_documento' => NULL,
                'monto' => 150000,
                'estado_gasto' => 'Pendiente',
                'comentario_validador' => NULL,
                'tipo_documento' => 'Comprobante de Transferencia',
                'detalle' => 'Alojamiento',
                'id_rendicion' => 2,
                'id_validador' => NULL,
            ),
            11 => 
            array (
                'id_gasto' => 13,
                'fecha' => '2026-02-05',
                'num_documento' => NULL,
                'monto' => 80000,
                'estado_gasto' => 'Pendiente',
                'comentario_validador' => NULL,
                'tipo_documento' => 'Comprobante de transferencia',
                'detalle' => 'Alojamiento',
                'id_rendicion' => 2,
                'id_validador' => NULL,
            ),
            12 => 
            array (
                'id_gasto' => 14,
                'fecha' => '2026-02-03',
                'num_documento' => 'RC8RR3APRA',
                'monto' => 30619,
                'estado_gasto' => 'Pendiente',
                'comentario_validador' => NULL,
                'tipo_documento' => 'Recibo Airbnb',
                'detalle' => 'Alojamiento',
                'id_rendicion' => 3,
                'id_validador' => NULL,
            ),
            13 => 
            array (
                'id_gasto' => 16,
                'fecha' => '2026-02-03',
                'num_documento' => NULL,
                'monto' => 16290,
                'estado_gasto' => 'Pendiente',
                'comentario_validador' => NULL,
                'tipo_documento' => 'Recibo JustBurger',
                'detalle' => 'Alimentación',
                'id_rendicion' => 3,
                'id_validador' => NULL,
            ),
            14 => 
            array (
                'id_gasto' => 17,
                'fecha' => '2026-02-03',
                'num_documento' => NULL,
                'monto' => 1434,
                'estado_gasto' => 'Pendiente',
                'comentario_validador' => NULL,
                'tipo_documento' => 'Recibo Uber',
                'detalle' => 'Transporte',
                'id_rendicion' => 3,
                'id_validador' => NULL,
            ),
            15 => 
            array (
                'id_gasto' => 18,
                'fecha' => '2026-02-09',
                'num_documento' => '001021954',
                'monto' => 41470,
                'estado_gasto' => 'Pendiente',
                'comentario_validador' => NULL,
                'tipo_documento' => 'Boleta',
                'detalle' => 'Alimentación',
                'id_rendicion' => 4,
                'id_validador' => NULL,
            ),
            16 => 
            array (
                'id_gasto' => 19,
                'fecha' => '2026-02-10',
                'num_documento' => '00',
                'monto' => 4147,
                'estado_gasto' => 'Pendiente',
                'comentario_validador' => NULL,
                'tipo_documento' => 'Ticket',
                'detalle' => 'propina',
                'id_rendicion' => 4,
                'id_validador' => NULL,
            ),
        ));
        
        
    }
}