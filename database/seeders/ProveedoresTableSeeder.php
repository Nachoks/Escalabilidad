<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ProveedoresTableSeeder extends Seeder
{
    public function run()
    {
        DB::table('proveedores')->insert([
            ['id_proveedor' => 1, 'nombre_proveedor' => 'ABB Chile', 'created_at' => now(), 'updated_at' => now()],
            ['id_proveedor' => 2, 'nombre_proveedor' => 'Rittal', 'created_at' => now(), 'updated_at' => now()],
            ['id_proveedor' => 3, 'nombre_proveedor' => 'Phoenix Contact.', 'created_at' => now(), 'updated_at' => now()],
            ['id_proveedor' => 4, 'nombre_proveedor' => 'Interlog', 'created_at' => now(), 'updated_at' => now()],

        ]);
    }
}

