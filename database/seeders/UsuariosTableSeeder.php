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
                'password' => '$2y$12$lidw6hTwJzKGBWv5deckHu7.P.7C3Dvqyf9SEppABGy/OPrzGG2TO',
                'onesignal_id' => 'c84ef8b6-4196-4e09-b7d1-783a8ef6ce2d',
                'created_at' => '2026-02-03 19:34:09',
                'updated_at' => '2026-02-09 20:06:51',
                'estado' => 1,
                'id_personal' => 1,
            ),
            1 => 
            array (
                'id_usuario' => 2,
                'nombre_usuario' => 'carenas',
                'password' => '$2y$12$XTdd2wGDErXTZGYprqG5uu76oXUC/JUb2xxjhoZPFNqKNvsk5ocdq',
                'onesignal_id' => '588ac04f-05ef-4bfe-86b0-83f9985416c9',
                'created_at' => '2026-02-03 19:34:10',
                'updated_at' => '2026-02-10 15:16:03',
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
                'onesignal_id' => '0b0a572f-e996-4319-8d97-d300adb7bf10',
                'created_at' => '2026-02-03 19:34:10',
                'updated_at' => '2026-02-09 19:12:02',
                'estado' => 1,
                'id_personal' => 4,
            ),
            4 => 
            array (
                'id_usuario' => 5,
                'nombre_usuario' => 'fperez',
                'password' => '$2y$12$CSCZvxWIZirU66FMOv9yGu7xVVDAyBkVFcdxHwuyVOBvw5dDY8bb2',
                'onesignal_id' => '6d15ead4-9813-42bb-a40c-adaeb6999da0',
                'created_at' => '2026-02-03 19:34:10',
                'updated_at' => '2026-02-09 20:12:48',
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
                'onesignal_id' => '193fbda6-e4c0-425a-8ca0-1871e42ddfc3',
                'created_at' => '2026-02-03 19:34:12',
                'updated_at' => '2026-02-10 14:01:38',
                'estado' => 1,
                'id_personal' => 10,
            ),
            10 => 
            array (
                'id_usuario' => 11,
                'nombre_usuario' => 'pzamora',
                'password' => '$2y$12$O2/Yyg8U00WNnxyFmJfNDuqgKSkdUNnEfTRNdtzl7A4FcGL8L.HHm',
                'onesignal_id' => '756f7e18-111f-4d73-a8fc-babfc1d910a6',
                'created_at' => '2026-02-03 19:34:12',
                'updated_at' => '2026-02-09 20:01:19',
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
                'onesignal_id' => '5ff35698-07bf-4c83-a846-1801d1c09437',
                'created_at' => '2026-02-03 19:34:13',
                'updated_at' => '2026-02-09 20:05:00',
                'estado' => 1,
                'id_personal' => 13,
            ),
            13 => 
            array (
                'id_usuario' => 14,
                'nombre_usuario' => 'tester',
                'password' => '$2y$12$/8w/ITEaw5YMTtqRi8UfKes3aolyaTk8g4UqVBoIZnpJeKnf76K8K',
                'onesignal_id' => 'b44b43c5-360f-4044-8c62-294b9e7b5b6e',
                'created_at' => '2026-02-03 19:34:13',
                'updated_at' => '2026-02-10 12:58:52',
                'estado' => 1,
                'id_personal' => 14,
            ),
        ));
        
        
    }
}