<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\Empresa;
use App\Models\AreaEmpresa;
use App\Models\Personal;
use App\Models\User;
use App\Models\TipoUsuario;
use App\Models\Vehiculo;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Crear Empresa
        $empresa = Empresa::create([
            'nombre_empresa' => 'Arenas y Arenas',
            'rol_empresa' => 'Matriz' // O el rol que quieras poner
        ]);

        // 2. Crear las Áreas vinculadas a esa empresa
        
        // Área 1: Automatización (Código 1)
        AreaEmpresa::create([
            'id_empresa' => $empresa->id_empresa, // Usamos el ID de la empresa creada
            'nombre_area' => 'Automatización',
            'codigo_area' => 1
        ]);

        // 2. Crear Tipos de Usuario (Roles)
        $rolAdmin = TipoUsuario::create(['tipo_usuario' => 'Administrador']);
        $rolConductor = TipoUsuario::create(['tipo_usuario' => 'Conductor']);

        // 3. Crear Personal y Usuarios (TODOS LOS CONDUCTORES)
        $conductores = [
            ['usuario' => 'amartinez', 'nombre' => 'Ariel', 'apellido' => 'Martinez', 'rut' => '12.345.678-9'],
            ['usuario' => 'carenas', 'nombre' => 'Camilo', 'apellido' => 'Arenas', 'rut' => '13.456.789-0'],
            ['usuario' => 'carenasc', 'nombre' => 'Camilo', 'apellido' => 'Arenas', 'rut' => '14.567.890-1'],
            ['usuario' => 'cmitchell', 'nombre' => 'Cristopher', 'apellido' => 'Mitchell', 'rut' => '15.678.901-2'],
            ['usuario' => 'fperez', 'nombre' => 'Felipe', 'apellido' => 'Perez', 'rut' => '16.789.012-3'],
            ['usuario' => 'glillo', 'nombre' => 'Gabriela', 'apellido' => 'Lillo', 'rut' => '17.890.123-4'],
            ['usuario' => 'ierazo', 'nombre' => 'Italo', 'apellido' => 'Erazo', 'rut' => '18.901.234-5'],
            ['usuario' => 'kpenaylillo', 'nombre' => 'Kevin', 'apellido' => 'Pena y Lillo', 'rut' => '19.012.345-6'],
            ['usuario' => 'mdiaz', 'nombre' => 'Mauricio', 'apellido' => 'Diaz', 'rut' => '20.123.456-7'],
            ['usuario' => 'mvielma', 'nombre' => 'Martin', 'apellido' => 'Vielma', 'rut' => '21.234.567-8'],
            ['usuario' => 'pzamora', 'nombre' => 'Patricio', 'apellido' => 'Zamora', 'rut' => '22.345.678-9'],
            ['usuario' => 'rzamora', 'nombre' => 'Ruben', 'apellido' => 'Zamora', 'rut' => '23.456.789-0'],
            ['usuario' => 'scortes', 'nombre' => 'Sebastian', 'apellido' => 'Cortes', 'rut' => '24.567.890-1'],
        ];

        foreach ($conductores as $conductor) {
            // Crear personal
            $personal = Personal::create([
                'nombre_personal' => $conductor['nombre'],
                'apellido_personal' => $conductor['apellido'],
                'rut' => $conductor['rut'],
                'id_empresa' => $empresa->id_empresa,
            ]);

            // Crear usuario
            $usuario = User::create([
                'nombre_usuario' => $conductor['usuario'],
                'password' => Hash::make('123456'), // Contraseña por defecto
                'id_personal' => $personal->id_personal,
            ]);

            // Asignar rol de Conductor
            $usuario->roles()->attach($rolConductor->id_tipo_usuario);
        }

        // 4. Crear Usuario Administrador
        $personalAdmin = Personal::create([
            'nombre_personal' => 'Tester',
            'apellido_personal' => 'Tester',
            'rut' => '10.111.222-3',
            'id_empresa' => $empresa->id_empresa,
        ]);

        $usuarioAdmin = User::create([
            'nombre_usuario' => 'tester',
            'password' => Hash::make('123456'),
            'id_personal' => $personalAdmin->id_personal,
        ]);

        $usuarioAdmin->roles()->attach($rolAdmin->id_tipo_usuario);

        // 5. Crear Vehículos
        $vehiculos = [
            ['patente' => 'TXYH73', 'disponibilidad' => 'Disponible'],
        ];

        foreach ($vehiculos as $vehiculo) {
            Vehiculo::create([
                'patente' => $vehiculo['patente'],
                'disponibilidad' => $vehiculo['disponibilidad'],
                'id_empresa' => $empresa->id_empresa,
            ]);
        }

        // Mensajes informativos

    }
}