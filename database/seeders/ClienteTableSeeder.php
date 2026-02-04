<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class ClienteTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('cliente')->delete();
        
        \DB::table('cliente')->insert(array (
            0 => 
            array (
                'id_cliente' => 1,
                'cod_cliente' => '00',
                'nombre_cliente' => 'Arenas & Arenas',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-03 19:58:42',
                'updated_at' => '2026-02-03 19:58:42',
            ),
            1 => 
            array (
                'id_cliente' => 2,
                'cod_cliente' => '01',
                'nombre_cliente' => 'Minera Centinela',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-03 19:58:56',
                'updated_at' => '2026-02-03 19:58:56',
            ),
            2 => 
            array (
                'id_cliente' => 3,
                'cod_cliente' => '02',
                'nombre_cliente' => 'Softys',
                'correo_representante' => 'nodefinido@no.cl',
                'nombre_representante' => 'No Definido',
                'created_at' => '2026-02-03 19:59:13',
                'updated_at' => '2026-02-03 19:59:13',
            ),
        ));
        
        
    }
}