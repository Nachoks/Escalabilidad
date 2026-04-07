<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class InventarioEntradasTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('inventario_entradas')->delete();
        
        \DB::table('inventario_entradas')->insert(array (
            0 => 
            array (
                'id_entrada' => 1,
                'id_producto' => 1,
                'id_responsable' => 14,
                'oc_proveedor' => NULL,
                'serial' => '654321',
                'estado_serial' => 'Entregado',
                'created_at' => '2026-03-24 15:39:41',
                'updated_at' => '2026-03-25 21:06:52',
            ),
            1 => 
            array (
                'id_entrada' => 2,
                'id_producto' => 1,
                'id_responsable' => 14,
                'oc_proveedor' => NULL,
                'serial' => '987654',
                'estado_serial' => 'Entregado',
                'created_at' => '2026-03-24 15:39:55',
                'updated_at' => '2026-03-25 21:11:24',
            ),
            2 => 
            array (
                'id_entrada' => 3,
                'id_producto' => 1,
                'id_responsable' => 14,
                'oc_proveedor' => NULL,
                'serial' => '987654321',
                'estado_serial' => 'Disponible',
                'created_at' => '2026-03-24 15:40:05',
                'updated_at' => '2026-03-24 15:40:05',
            ),
            3 => 
            array (
                'id_entrada' => 4,
                'id_producto' => 2,
                'id_responsable' => 14,
                'oc_proveedor' => NULL,
                'serial' => '654987',
                'estado_serial' => 'Disponible',
                'created_at' => '2026-03-24 15:41:05',
                'updated_at' => '2026-03-24 15:41:05',
            ),
            4 => 
            array (
                'id_entrada' => 5,
                'id_producto' => 1,
                'id_responsable' => 14,
                'oc_proveedor' => '123335',
                'serial' => '741852',
                'estado_serial' => 'Disponible',
                'created_at' => '2026-03-25 21:06:13',
                'updated_at' => '2026-03-25 21:06:13',
            ),
            5 => 
            array (
                'id_entrada' => 6,
                'id_producto' => 3,
                'id_responsable' => 14,
                'oc_proveedor' => '85296',
                'serial' => '258369',
                'estado_serial' => 'Entregado',
                'created_at' => '2026-03-26 17:42:37',
                'updated_at' => '2026-03-26 17:43:39',
            ),
            6 => 
            array (
                'id_entrada' => 7,
                'id_producto' => 4,
                'id_responsable' => 14,
                'oc_proveedor' => '12345',
                'serial' => 'SC07167442',
                'estado_serial' => 'Disponible',
                'created_at' => '2026-04-01 21:54:43',
                'updated_at' => '2026-04-01 21:54:43',
            ),
            7 => 
            array (
                'id_entrada' => 8,
                'id_producto' => 4,
                'id_responsable' => 14,
                'oc_proveedor' => '103839',
                'serial' => 'SC0716744292C',
                'estado_serial' => 'Disponible',
                'created_at' => '2026-04-01 22:17:32',
                'updated_at' => '2026-04-01 22:17:32',
            ),
            8 => 
            array (
                'id_entrada' => 9,
                'id_producto' => 5,
                'id_responsable' => 14,
                'oc_proveedor' => 'escaneo2',
                'serial' => 'SM24153343',
                'estado_serial' => 'Entregado',
                'created_at' => '2026-04-01 22:32:26',
                'updated_at' => '2026-04-01 22:32:47',
            ),
            9 => 
            array (
                'id_entrada' => 10,
                'id_producto' => 6,
                'id_responsable' => 14,
                'oc_proveedor' => '0000',
                'serial' => 'SX24155597',
                'estado_serial' => 'Disponible',
                'created_at' => '2026-04-01 22:33:35',
                'updated_at' => '2026-04-01 22:33:35',
            ),
            10 => 
            array (
                'id_entrada' => 11,
                'id_producto' => 7,
                'id_responsable' => 14,
                'oc_proveedor' => '0989',
                'serial' => 'SC24020692',
                'estado_serial' => 'Disponible',
                'created_at' => '2026-04-01 22:34:24',
                'updated_at' => '2026-04-01 22:34:24',
            ),
            11 => 
            array (
                'id_entrada' => 12,
                'id_producto' => 8,
                'id_responsable' => 14,
                'oc_proveedor' => '948738',
                'serial' => 'SM23477311',
                'estado_serial' => 'Disponible',
                'created_at' => '2026-04-01 22:36:38',
                'updated_at' => '2026-04-01 22:36:38',
            ),
            12 => 
            array (
                'id_entrada' => 13,
                'id_producto' => 4,
                'id_responsable' => 14,
                'oc_proveedor' => '85863',
                'serial' => 'SZ253000P6',
                'estado_serial' => 'Disponible',
                'created_at' => '2026-04-02 19:23:45',
                'updated_at' => '2026-04-02 19:23:45',
            ),
            13 => 
            array (
                'id_entrada' => 14,
                'id_producto' => 9,
                'id_responsable' => 14,
                'oc_proveedor' => '637395',
                'serial' => 'SC23240291',
                'estado_serial' => 'Entregado',
                'created_at' => '2026-04-02 19:24:59',
                'updated_at' => '2026-04-02 19:45:00',
            ),
            14 => 
            array (
                'id_entrada' => 15,
                'id_producto' => 10,
                'id_responsable' => 14,
                'oc_proveedor' => '090909',
                'serial' => '4002044389260',
                'estado_serial' => 'Disponible',
                'created_at' => '2026-04-02 19:34:29',
                'updated_at' => '2026-04-02 19:34:29',
            ),
            15 => 
            array (
                'id_entrada' => 16,
                'id_producto' => 11,
                'id_responsable' => 14,
                'oc_proveedor' => '293738',
                'serial' => 'SI12098411',
                'estado_serial' => 'Disponible',
                'created_at' => '2026-04-02 19:44:29',
                'updated_at' => '2026-04-02 19:44:29',
            ),
        ));
        
        
    }
}