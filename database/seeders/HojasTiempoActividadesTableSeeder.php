<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class HojasTiempoActividadesTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('hojas_tiempo_actividades')->delete();
        
        \DB::table('hojas_tiempo_actividades')->insert(array (
            0 => 
            array (
                'id_actividad' => 9,
                'id_hoja_diaria' => 51,
                'hora_inicio' => '09:00:00',
                'hora_fin' => '10:50:00',
                'descripcion' => 'Espera habilitación de ingreso a Softys Talagante.',
                'horas_habiles' => 1.8,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-23 15:56:40',
                'updated_at' => '2026-03-23 15:56:40',
            ),
            1 => 
            array (
                'id_actividad' => 10,
                'id_hoja_diaria' => 51,
                'hora_inicio' => '10:50:00',
                'hora_fin' => '11:30:00',
                'descripcion' => 'Ingreso al area, inicio de actividades.',
                'horas_habiles' => 0.66666666666667,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-23 15:56:40',
                'updated_at' => '2026-03-23 15:56:40',
            ),
            2 => 
            array (
                'id_actividad' => 11,
                'id_hoja_diaria' => 51,
                'hora_inicio' => '11:30:00',
                'hora_fin' => '13:45:00',
                'descripcion' => 'Verificación estado sistema 800xA y servidores.',
                'horas_habiles' => 2.3,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-23 15:56:40',
                'updated_at' => '2026-03-23 15:56:40',
            ),
            3 => 
            array (
                'id_actividad' => 12,
                'id_hoja_diaria' => 51,
                'hora_inicio' => '13:45:00',
                'hora_fin' => '18:00:00',
                'descripcion' => 'Apagado y encendido de servidores, maquinas virtualesy estaciones de operación para mantención de sala eléctrica.',
                'horas_habiles' => 4.25,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-23 15:56:40',
                'updated_at' => '2026-03-23 15:56:40',
            ),
            4 => 
            array (
                'id_actividad' => 13,
                'id_hoja_diaria' => 52,
                'hora_inicio' => '09:00:00',
                'hora_fin' => '10:00:00',
                'descripcion' => 'Inicio de trabajo, coordinación de desconexión sala electrica.',
                'horas_habiles' => 1.0,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-23 17:33:06',
                'updated_at' => '2026-03-23 17:33:06',
            ),
            5 => 
            array (
                'id_actividad' => 14,
                'id_hoja_diaria' => 52,
                'hora_inicio' => '10:00:00',
                'hora_fin' => '10:30:00',
                'descripcion' => 'Apagado del servidor para mantenimiento de sala electrica.',
                'horas_habiles' => 0.5,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-23 17:33:06',
                'updated_at' => '2026-03-23 17:33:06',
            ),
            6 => 
            array (
                'id_actividad' => 15,
                'id_hoja_diaria' => 52,
                'hora_inicio' => '11:30:00',
                'hora_fin' => '13:45:00',
                'descripcion' => 'Encendido de servidores y verificación de sistema 800xA.',
                'horas_habiles' => 2.2222222222222,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-23 17:33:06',
                'updated_at' => '2026-03-23 17:33:06',
            ),
            7 => 
            array (
                'id_actividad' => 16,
                'id_hoja_diaria' => 52,
                'hora_inicio' => '10:30:00',
                'hora_fin' => '11:30:00',
                'descripcion' => 'Limpieza de estaciones de operación y periféricos.',
                'horas_habiles' => 1.0,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-23 17:33:06',
                'updated_at' => '2026-03-23 17:33:06',
            ),
            8 => 
            array (
                'id_actividad' => 17,
                'id_hoja_diaria' => 52,
                'hora_inicio' => '13:45:00',
                'hora_fin' => '18:00:00',
                'descripcion' => 'Chequeo de gabinete de control e I/O, chequeo de estado del controlador en control builder y de pantallas de operación',
                'horas_habiles' => 4.25,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-23 17:33:06',
                'updated_at' => '2026-03-23 17:33:06',
            ),
            9 => 
            array (
                'id_actividad' => 18,
                'id_hoja_diaria' => 53,
                'hora_inicio' => '09:00:00',
                'hora_fin' => '10:00:00',
                'descripcion' => 'Inicio de trabajo.
Espera de instrucciones por parte de personal de Softys.',
                'horas_habiles' => 1.0,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-23 17:37:04',
                'updated_at' => '2026-03-23 17:37:04',
            ),
            10 => 
            array (
                'id_actividad' => 19,
                'id_hoja_diaria' => 53,
                'hora_inicio' => '10:00:00',
                'hora_fin' => '18:00:00',
                'descripcion' => 'Comunicación con configurador RTU y encargado Softys para mostrar en despliegue gráfico potencia acumulada.
Configuración de lógica para integración de potencia activa.',
                'horas_habiles' => 8.0,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-23 17:37:04',
                'updated_at' => '2026-03-23 17:37:04',
            ),
            11 => 
            array (
                'id_actividad' => 23,
                'id_hoja_diaria' => 72,
                'hora_inicio' => '09:00:00',
                'hora_fin' => '10:50:00',
                'descripcion' => 'Espera habilitación de ingreso a Softys Talagante.',
                'horas_habiles' => 1.8333333333333,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-24 20:40:21',
                'updated_at' => '2026-03-24 20:40:21',
            ),
            12 => 
            array (
                'id_actividad' => 24,
                'id_hoja_diaria' => 72,
                'hora_inicio' => '10:50:00',
                'hora_fin' => '11:30:00',
                'descripcion' => 'Ingreso al area, inicio de actividades.',
                'horas_habiles' => 0.66666666666667,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-24 20:40:21',
                'updated_at' => '2026-03-24 20:40:21',
            ),
            13 => 
            array (
                'id_actividad' => 25,
                'id_hoja_diaria' => 72,
                'hora_inicio' => '11:30:00',
                'hora_fin' => '13:45:00',
                'descripcion' => 'Verificación estado sistema 800xA y servidores.',
                'horas_habiles' => 2.25,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-24 20:40:21',
                'updated_at' => '2026-03-24 20:40:21',
            ),
            14 => 
            array (
                'id_actividad' => 26,
                'id_hoja_diaria' => 72,
                'hora_inicio' => '13:45:00',
                'hora_fin' => '18:00:00',
                'descripcion' => 'Apagado y encendido de servidores, maquinas virtualesy estaciones de
operación para mantención de sala eléctrica.',
                'horas_habiles' => 4.25,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-24 20:40:21',
                'updated_at' => '2026-03-24 20:40:21',
            ),
            15 => 
            array (
                'id_actividad' => 27,
                'id_hoja_diaria' => 73,
                'hora_inicio' => '09:00:00',
                'hora_fin' => '10:00:00',
                'descripcion' => 'Inicio de trabajo, coordinación de desconexión sala electrica',
                'horas_habiles' => 1.0,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-24 20:44:54',
                'updated_at' => '2026-03-24 20:44:54',
            ),
            16 => 
            array (
                'id_actividad' => 28,
                'id_hoja_diaria' => 73,
                'hora_inicio' => '10:00:00',
                'hora_fin' => '10:30:00',
                'descripcion' => 'Apagado del servidor para mantenimiento de sala electrica.',
                'horas_habiles' => 0.5,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-24 20:44:54',
                'updated_at' => '2026-03-24 20:44:54',
            ),
            17 => 
            array (
                'id_actividad' => 29,
                'id_hoja_diaria' => 73,
                'hora_inicio' => '10:30:00',
                'hora_fin' => '11:30:00',
                'descripcion' => 'Limpieza de estaciones de operación y periféricos.',
                'horas_habiles' => 1.0,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-24 20:44:54',
                'updated_at' => '2026-03-24 20:44:54',
            ),
            18 => 
            array (
                'id_actividad' => 30,
                'id_hoja_diaria' => 73,
                'hora_inicio' => '11:30:00',
                'hora_fin' => '13:45:00',
                'descripcion' => 'Encendido de servidores y verificación de sistema 800xA.',
                'horas_habiles' => 2.25,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-24 20:44:54',
                'updated_at' => '2026-03-24 20:44:54',
            ),
            19 => 
            array (
                'id_actividad' => 31,
                'id_hoja_diaria' => 73,
                'hora_inicio' => '13:45:00',
                'hora_fin' => '18:00:00',
                'descripcion' => 'hequeo de gabinete de control e I/O, chequeo de estado del controlador en
control builder y de pantallas de operación.',
                'horas_habiles' => 4.25,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-24 20:44:54',
                'updated_at' => '2026-03-24 20:44:54',
            ),
            20 => 
            array (
                'id_actividad' => 32,
                'id_hoja_diaria' => 74,
                'hora_inicio' => '09:00:00',
                'hora_fin' => '10:00:00',
                'descripcion' => 'Inicio de trabajo.
Espera de instrucciones por parte de personal de Softys.',
                'horas_habiles' => 1.0,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-24 20:45:59',
                'updated_at' => '2026-03-24 20:45:59',
            ),
            21 => 
            array (
                'id_actividad' => 33,
                'id_hoja_diaria' => 74,
                'hora_inicio' => '10:00:00',
                'hora_fin' => '18:00:00',
                'descripcion' => 'Comunicación con configurador RTU y encargado Softys para mostrar en
despliegue gráfico potencia acumulada.
Configuración de lógica para integración de potencia activa.',
                'horas_habiles' => 8.0,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-03-24 20:45:59',
                'updated_at' => '2026-03-24 20:45:59',
            ),
            22 => 
            array (
                'id_actividad' => 34,
                'id_hoja_diaria' => 79,
                'hora_inicio' => '15:00:00',
                'hora_fin' => '17:50:00',
                'descripcion' => 'Integracion de Señales BESS en PV PPC',
                'horas_habiles' => 2.8333333333333,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-04-01 15:50:27',
                'updated_at' => '2026-04-01 15:50:27',
            ),
            23 => 
            array (
                'id_actividad' => 35,
                'id_hoja_diaria' => 80,
                'hora_inicio' => '14:30:00',
                'hora_fin' => '18:00:00',
                'descripcion' => 'Configuraciones en PV PCC',
                'horas_habiles' => 3.5,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-04-02 14:34:41',
                'updated_at' => '2026-04-02 14:34:41',
            ),
            24 => 
            array (
                'id_actividad' => 37,
                'id_hoja_diaria' => 81,
                'hora_inicio' => '08:30:00',
                'hora_fin' => '11:00:00',
                'descripcion' => 'Configuración de señales GPM',
                'horas_habiles' => 2.5,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-04-02 20:33:15',
                'updated_at' => '2026-04-02 20:33:15',
            ),
            25 => 
            array (
                'id_actividad' => 38,
                'id_hoja_diaria' => 81,
                'hora_inicio' => '16:00:00',
                'hora_fin' => '17:30:00',
                'descripcion' => 'Pruebas comandos desde Bess',
                'horas_habiles' => 1.5,
                'horas_no_habiles' => 0.0,
                'horas_festivas' => 0.0,
                'created_at' => '2026-04-02 20:33:15',
                'updated_at' => '2026-04-02 20:33:15',
            ),
        ));
        
        
    }
}