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
                'onesignal_id' => '923c7753-1332-4222-8da9-0977f4100b3d',
                'created_at' => '2026-02-03 19:34:09',
                'updated_at' => '2026-03-23 17:19:13',
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
                'updated_at' => '2026-04-05 17:59:52',
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
                'password' => '$2y$12$EjqFKUoU3/OTTEuHbG/yA.dGkIqORLYRLm2CNYOx2jxl0mnpE4I7O',
                'onesignal_id' => '0b0a572f-e996-4319-8d97-d300adb7bf10',
                'created_at' => '2026-02-03 19:34:10',
                'updated_at' => '2026-02-11 20:21:05',
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
                'password' => '$2y$12$wv2e1jsZihTgo6Q1/tSVvO9A8hd2zH3E0FtonkhE.qMi2PixNvkRq',
                'onesignal_id' => 'c8ac4d94-544c-4f6d-bdde-59f52637fa11',
                'created_at' => '2026-02-03 19:34:11',
                'updated_at' => '2026-03-11 20:13:01',
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
                'updated_at' => '2026-04-06 20:40:04',
                'estado' => 1,
                'id_personal' => 8,
            ),
            8 => 
            array (
                'id_usuario' => 9,
                'nombre_usuario' => 'mdiaz',
                'password' => '$2y$12$O0rqRJZxqCrqhXPCeECOEeFNVZGPtS5Adglhbyny3Y5JCfhDZBFz6',
                'onesignal_id' => '33390e81-8880-4ce3-ab96-0108b0215408',
                'created_at' => '2026-02-03 19:34:12',
                'updated_at' => '2026-02-11 20:26:21',
                'estado' => 1,
                'id_personal' => 9,
            ),
            9 => 
            array (
                'id_usuario' => 10,
                'nombre_usuario' => 'mvielma',
                'password' => '$2y$12$bNnxTDVrPmtIEIXe.AG1o.Am2h78WHTLwLrjSaOglkrIs2sBmSgNy',
                'onesignal_id' => 'b4ca5839-1695-4b9e-a5ee-c37bf2cb31a7',
                'created_at' => '2026-02-03 19:34:12',
                'updated_at' => '2026-03-11 15:57:16',
                'estado' => 1,
                'id_personal' => 10,
            ),
            10 => 
            array (
                'id_usuario' => 11,
                'nombre_usuario' => 'pzamora',
                'password' => '$2y$12$O2/Yyg8U00WNnxyFmJfNDuqgKSkdUNnEfTRNdtzl7A4FcGL8L.HHm',
                'onesignal_id' => 'adf90cc5-51f6-4fb0-b51e-8d4142f7ab96',
                'created_at' => '2026-02-03 19:34:12',
                'updated_at' => '2026-04-06 20:50:32',
                'estado' => 1,
                'id_personal' => 11,
            ),
            11 => 
            array (
                'id_usuario' => 12,
                'nombre_usuario' => 'rzamora',
                'password' => '$2y$12$XHaBRqfy5TeL5PJ3rSMYQOBZ22AbWv2UB5V5smAwx4YHom7P9Q2jy',
                'onesignal_id' => '07dec5f1-e26e-4063-b9bf-93cc7adfbb15',
                'created_at' => '2026-02-03 19:34:13',
                'updated_at' => '2026-02-24 16:03:59',
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
                'password' => '$2y$12$YDCD6E0kzKptFOGSNovaZeesW1C95Mgt0.pjrUCRHk/KpZ3y6zLAe',
                'onesignal_id' => '8ada6164-df36-4657-a243-aaaade682b4c',
                'created_at' => '2026-02-03 19:34:13',
                'updated_at' => '2026-04-02 18:17:45',
                'estado' => 1,
                'id_personal' => 14,
            ),
        ));
        
        
    }
}