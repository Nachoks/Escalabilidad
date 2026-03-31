<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class ProveedoresTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('proveedores')->delete();
        
        \DB::table('proveedores')->insert(array (
            0 => 
            array (
                'id_proveedor' => 1,
                'nombre_proveedor' => 'ABB Chile',
                'nombre_contacto' => 'Erick Fernandez',
                'numero_contacto' => '56 9 8453 9470',
                'correo_contacto' => NULL,
                'created_at' => '2026-03-24 15:34:00',
                'updated_at' => '2026-03-24 15:34:00',
            ),
            1 => 
            array (
                'id_proveedor' => 2,
                'nombre_proveedor' => 'Rittal',
                'nombre_contacto' => 'Manuel Hidalgo',
                'numero_contacto' => '59 9 3427 7225',
                'correo_contacto' => 'hidalgo.m@rittal.cl',
                'created_at' => '2026-03-24 15:34:21',
                'updated_at' => '2026-03-24 15:34:21',
            ),
            2 => 
            array (
                'id_proveedor' => 3,
                'nombre_proveedor' => 'Phoenix Contact.',
                'nombre_contacto' => 'Erika Patiño',
                'numero_contacto' => '56 9 9934 4595',
                'correo_contacto' => 'jacuna@phoenixcontact.com',
                'created_at' => '2026-03-24 15:34:41',
                'updated_at' => '2026-03-24 15:34:41',
            ),
            3 => 
            array (
                'id_proveedor' => 4,
                'nombre_proveedor' => 'Interlog',
                'nombre_contacto' => 'Juan Pablo Gallay',
                'numero_contacto' => '56 9 6190 6237',
                'correo_contacto' => 'jpgallay@interlog-it.com',
                'created_at' => '2026-03-24 15:34:58',
                'updated_at' => '2026-03-24 15:34:58',
            ),
        ));
        
        
    }
}