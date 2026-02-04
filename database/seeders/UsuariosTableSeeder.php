<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class UsuariosTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('usuarios')->delete();
        
        \DB::table('usuarios')->insert(array (
            0 => 
            array (
                'id_usuario' => 1,
                'nombre_usuario' => 'amartinez',
                'password' => '$2y$12$l99GpHJ/.jvZO6OSXTf8qu/7NP1aAgz9sWG0gTXojRoRCHq2BNoce',
                'onesignal_id' => NULL,
                'created_at' => '2026-02-03 19:34:09',
                'updated_at' => '2026-02-03 19:34:09',
                'estado' => 1,
                'id_personal' => 1,
            ),
            1 => 
            array (
                'id_usuario' => 2,
                'nombre_usuario' => 'carenas',
                'password' => '$2y$12$XTdd2wGDErXTZGYprqG5uu76oXUC/JUb2xxjhoZPFNqKNvsk5ocdq',
                'onesignal_id' => NULL,
                'created_at' => '2026-02-03 19:34:10',
                'updated_at' => '2026-02-03 19:34:10',
                'estado' => 1,
                'id_personal' => 2,
            ),
            2 => 
            array (
                'id_usuario' => 3,
                'nombre_usuario' => 'carenasc',
                'password' => '$2y$12$yFilo5gLzQnLo5Jn5hwcZu/tXpgHp536iQJ726gxozdcUDkq1dlL2',
                'onesignal_id' => NULL,
                'created_at' => '2026-02-03 19:34:10',
                'updated_at' => '2026-02-03 19:34:10',
                'estado' => 1,
                'id_personal' => 3,
            ),
            3 => 
            array (
                'id_usuario' => 4,
                'nombre_usuario' => 'cmitchell',
                'password' => '$2y$12$Os5niv0Yi1Ho.NFa6p0xM.WlFxTxuK6To6i4utqn4yC9NlH2OIcFi',
                'onesignal_id' => NULL,
                'created_at' => '2026-02-03 19:34:10',
                'updated_at' => '2026-02-03 19:34:10',
                'estado' => 1,
                'id_personal' => 4,
            ),
            4 => 
            array (
                'id_usuario' => 5,
                'nombre_usuario' => 'fperez',
                'password' => '$2y$12$06Z9XrBr69FQXkLsGjQMOuyG4..bxp2ryQcb5Kt6SccYwSICpBgQW',
                'onesignal_id' => NULL,
                'created_at' => '2026-02-03 19:34:10',
                'updated_at' => '2026-02-03 19:34:10',
                'estado' => 1,
                'id_personal' => 5,
            ),
            5 => 
            array (
                'id_usuario' => 6,
                'nombre_usuario' => 'glillo',
                'password' => '$2y$12$QLlvRbMtODAfLQ.4uaU4FuaSyCsrsxaZ1FNf8px3V8J/ITMIrB29y',
                'onesignal_id' => NULL,
                'created_at' => '2026-02-03 19:34:11',
                'updated_at' => '2026-02-03 19:34:11',
                'estado' => 1,
                'id_personal' => 6,
            ),
            6 => 
            array (
                'id_usuario' => 7,
                'nombre_usuario' => 'ierazo',
                'password' => '$2y$12$woxhDg6zDsxHkBYZp3hyH.FCipCV8Wq4a4Juml0AqKazLeHi2XNb.',
                'onesignal_id' => NULL,
                'created_at' => '2026-02-03 19:34:11',
                'updated_at' => '2026-02-03 19:34:11',
                'estado' => 1,
                'id_personal' => 7,
            ),
            7 => 
            array (
                'id_usuario' => 8,
                'nombre_usuario' => 'kpenaylillo',
                'password' => '$2y$12$4qnD6nS0zy1YIwV3EXzs4uyoPGKocwhYPk2qfYUhs0cm3XLhv9VN6',
                'onesignal_id' => NULL,
                'created_at' => '2026-02-03 19:34:11',
                'updated_at' => '2026-02-03 19:34:11',
                'estado' => 1,
                'id_personal' => 8,
            ),
            8 => 
            array (
                'id_usuario' => 9,
                'nombre_usuario' => 'mdiaz',
                'password' => '$2y$12$O0rqRJZxqCrqhXPCeECOEeFNVZGPtS5Adglhbyny3Y5JCfhDZBFz6',
                'onesignal_id' => NULL,
                'created_at' => '2026-02-03 19:34:12',
                'updated_at' => '2026-02-03 19:34:12',
                'estado' => 1,
                'id_personal' => 9,
            ),
            9 => 
            array (
                'id_usuario' => 10,
                'nombre_usuario' => 'mvielma',
                'password' => '$2y$12$bNnxTDVrPmtIEIXe.AG1o.Am2h78WHTLwLrjSaOglkrIs2sBmSgNy',
                'onesignal_id' => NULL,
                'created_at' => '2026-02-03 19:34:12',
                'updated_at' => '2026-02-03 19:34:12',
                'estado' => 1,
                'id_personal' => 10,
            ),
            10 => 
            array (
                'id_usuario' => 11,
                'nombre_usuario' => 'pzamora',
                'password' => '$2y$12$1XDZBoVFxAl6ji1wkeaARuRKfrJdPkp07HfaadlPHZY6l.XCJFdhm',
                'onesignal_id' => NULL,
                'created_at' => '2026-02-03 19:34:12',
                'updated_at' => '2026-02-03 19:34:12',
                'estado' => 1,
                'id_personal' => 11,
            ),
            11 => 
            array (
                'id_usuario' => 12,
                'nombre_usuario' => 'rzamora',
                'password' => '$2y$12$XHaBRqfy5TeL5PJ3rSMYQOBZ22AbWv2UB5V5smAwx4YHom7P9Q2jy',
                'onesignal_id' => NULL,
                'created_at' => '2026-02-03 19:34:13',
                'updated_at' => '2026-02-03 19:34:13',
                'estado' => 1,
                'id_personal' => 12,
            ),
            12 => 
            array (
                'id_usuario' => 13,
                'nombre_usuario' => 'scortes',
                'password' => '$2y$12$4eeYsb3H4BX02T73aT9QNuLdqYpQyoSnRvT0YuMd4vYdeTYLaubqu',
                'onesignal_id' => NULL,
                'created_at' => '2026-02-03 19:34:13',
                'updated_at' => '2026-02-03 19:34:13',
                'estado' => 1,
                'id_personal' => 13,
            ),
            13 => 
            array (
                'id_usuario' => 14,
                'nombre_usuario' => 'tester',
                'password' => '$2y$12$/8w/ITEaw5YMTtqRi8UfKes3aolyaTk8g4UqVBoIZnpJeKnf76K8K',
                'onesignal_id' => 'efc31f1d-883a-42f4-97ee-ab575d34c531',
                'created_at' => '2026-02-03 19:34:13',
                'updated_at' => '2026-02-04 15:49:45',
                'estado' => 1,
                'id_personal' => 14,
            ),
        ));
        
        
    }
}