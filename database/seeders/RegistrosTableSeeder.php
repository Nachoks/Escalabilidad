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
            1 => 
            array (
                'id_registro_rendicion' => 2,
                'id_rendicion' => 3,
                'id_usuario_pagador' => 2,
                'fecha_pago' => '2026-02-11',
                'monto_pagado' => 48343,
                'nombre_original' => 'scaled_6d73ad32-2ad4-4f86-829c-88fca23c8b0f5452229335192230317.jpg',
                'nombre_fisico' => 'PAGO_1770840949.jpg',
                'ruta_relativa' => '003/pago/PAGO_1770840949.jpg',
                'peso_kb' => '1730.93',
                'extension' => 'jpg',
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            2 => 
            array (
                'id_registro_rendicion' => 3,
                'id_rendicion' => 3,
                'id_usuario_pagador' => 2,
                'fecha_pago' => '2026-02-11',
                'monto_pagado' => 0,
                'nombre_original' => 'Reporte Automático Generado.pdf',
                'nombre_fisico' => 'REPORTE_DETALLE_3_1770840949.pdf',
                'ruta_relativa' => '003/pago/REPORTE_DETALLE_3_1770840949.pdf',
                'peso_kb' => '896.95',
                'extension' => 'pdf',
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            3 => 
            array (
                'id_registro_rendicion' => 4,
                'id_rendicion' => 5,
                'id_usuario_pagador' => 2,
                'fecha_pago' => '2026-02-11',
                'monto_pagado' => 119675,
                'nombre_original' => 'scaled_be54b7ea-e526-4707-87c0-f2511dc63dae8709114027323182806.jpg',
                'nombre_fisico' => 'PAGO_1770841127.jpg',
                'ruta_relativa' => '005/pago/PAGO_1770841127.jpg',
                'peso_kb' => '1162.79',
                'extension' => 'jpg',
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            4 => 
            array (
                'id_registro_rendicion' => 5,
                'id_rendicion' => 5,
                'id_usuario_pagador' => 2,
                'fecha_pago' => '2026-02-11',
                'monto_pagado' => 0,
                'nombre_original' => 'Reporte Automático Generado.pdf',
                'nombre_fisico' => 'REPORTE_DETALLE_5_1770841127.pdf',
                'ruta_relativa' => '005/pago/REPORTE_DETALLE_5_1770841127.pdf',
                'peso_kb' => '4624.87',
                'extension' => 'pdf',
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            5 => 
            array (
                'id_registro_rendicion' => 6,
                'id_rendicion' => 6,
                'id_usuario_pagador' => 2,
                'fecha_pago' => '2026-02-12',
                'monto_pagado' => 75656,
                'nombre_original' => 'scaled_fab1f3d5-e38c-44b0-bba9-fb9df132603d5750551040158619503.jpg',
                'nombre_fisico' => 'PAGO_1770930139.jpg',
                'ruta_relativa' => '006/pago/PAGO_1770930139.jpg',
                'peso_kb' => '1026.64',
                'extension' => 'jpg',
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            6 => 
            array (
                'id_registro_rendicion' => 7,
                'id_rendicion' => 6,
                'id_usuario_pagador' => 2,
                'fecha_pago' => '2026-02-12',
                'monto_pagado' => 0,
                'nombre_original' => 'Reporte Automático Generado.pdf',
                'nombre_fisico' => 'REPORTE_DETALLE_6_1770930139.pdf',
                'ruta_relativa' => '006/pago/REPORTE_DETALLE_6_1770930139.pdf',
                'peso_kb' => '558.69',
                'extension' => 'pdf',
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            7 => 
            array (
                'id_registro_rendicion' => 8,
                'id_rendicion' => 2,
                'id_usuario_pagador' => 2,
                'fecha_pago' => '2026-02-12',
                'monto_pagado' => 598120,
                'nombre_original' => 'scaled_b428b093-58d1-4d15-b3cc-630a3b6a153a1388836695427364730.jpg',
                'nombre_fisico' => 'PAGO_1770930161.jpg',
                'ruta_relativa' => '002/pago/PAGO_1770930161.jpg',
                'peso_kb' => '1218.36',
                'extension' => 'jpg',
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            8 => 
            array (
                'id_registro_rendicion' => 9,
                'id_rendicion' => 2,
                'id_usuario_pagador' => 2,
                'fecha_pago' => '2026-02-12',
                'monto_pagado' => 0,
                'nombre_original' => 'Reporte Automático Generado.pdf',
                'nombre_fisico' => 'REPORTE_DETALLE_2_1770930161.pdf',
                'ruta_relativa' => '002/pago/REPORTE_DETALLE_2_1770930161.pdf',
                'peso_kb' => '3785.45',
                'extension' => 'pdf',
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            9 => 
            array (
                'id_registro_rendicion' => 10,
                'id_rendicion' => 8,
                'id_usuario_pagador' => 2,
                'fecha_pago' => '2026-02-18',
                'monto_pagado' => 142157,
                'nombre_original' => 'scaled_2b109e41-8bae-487f-801c-22525d860aea2763782454033428735.jpg',
                'nombre_fisico' => 'PAGO_1771449496.jpg',
                'ruta_relativa' => '008/pago/PAGO_1771449496.jpg',
                'peso_kb' => '987.38',
                'extension' => 'jpg',
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
            10 => 
            array (
                'id_registro_rendicion' => 11,
                'id_rendicion' => 8,
                'id_usuario_pagador' => 2,
                'fecha_pago' => '2026-02-18',
                'monto_pagado' => 0,
                'nombre_original' => 'Reporte Automático Generado.pdf',
                'nombre_fisico' => 'REPORTE_DETALLE_8_1771449496.pdf',
                'ruta_relativa' => '008/pago/REPORTE_DETALLE_8_1771449496.pdf',
                'peso_kb' => '4417.80',
                'extension' => 'pdf',
                'created_at' => NULL,
                'updated_at' => NULL,
            ),
        ));
        
        
    }
}