<?php


namespace Database\Seeders;


use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;


class TipoUsuarioTableSeeder extends Seeder
{
    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        // ELIMINAMOS el delete() para que la base de datos no arroje error.
        // Usamos updateOrInsert para que solo actualice los nombres y agregue los nuevos.
       
        $tipos = [
            [
                'id_tipo_usuario' => 1,
                'tipo_usuario' => 'Administrador'
            ],
            [
                'id_tipo_usuario' => 2,
                'tipo_usuario' => 'Conductor'
            ],
            [
                'id_tipo_usuario' => 3,
                'tipo_usuario' => 'Validador'
            ],
            [
                'id_tipo_usuario' => 4,
                'tipo_usuario' => 'Usuario' // <-- Se actualiza el nombre automáticamente
            ],
            [
                'id_tipo_usuario' => 5,
                'tipo_usuario' => 'Validador HT' // <-- Se agrega el nuevo rol
            ],
        ];


        foreach ($tipos as $tipo) {
            DB::table('tipo_usuario')->updateOrInsert(
                ['id_tipo_usuario' => $tipo['id_tipo_usuario']], // Busca por el ID
                [
                    'tipo_usuario' => $tipo['tipo_usuario'], // Actualiza el nombre
                    'created_at' => '2026-02-03 19:34:09',
                    'updated_at' => now(),
                ]
            );
        }
    }
}


