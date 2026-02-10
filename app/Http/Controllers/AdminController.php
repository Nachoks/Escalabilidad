<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use App\Models\Personal;
use App\Models\Empresa;
use App\Models\TipoUsuario;

class AdminController extends Controller
{
    // --- LISTAR USUARIOS ---
    public function listarUsuarios()
    {
        $users = User::with(['personal.empresa', 'roles'])->get();

        $usersOrdenados = $users->sortBy(function ($user) {
            return $user->personal ? $user->personal->nombre_personal : $user->nombre_usuario;
        })->values();

        return response()->json($usersOrdenados, 200);
    }

    // --- LISTAR EMPRESAS ---
    public function listarEmpresas()
    {
        $empresas = Empresa::select('id_empresa', 'nombre_empresa')->get();
        return response()->json($empresas, 200);
    }

    public function cambiarEstadoUsuario($id)
    {
        try {
            $user = User::findOrFail($id);
        
            $user->estado = !$user->estado; 
            $user->save();

            $texto = $user->estado ? 'Habilitado' : 'Deshabilitado';

            return response()->json([
                'message' => "Usuario $texto correctamente",
                'user' => $user
            ], 200);

        } catch (\Exception $e) {
            return response()->json(['message' => 'Error', 'error' => $e->getMessage()], 500);
        }
    }

    // --- CREAR USUARIO ---
    public function crearUsuario(Request $request)
    {
        $request->validate([
            'personal.nombre'     => 'required|string',
            'personal.apellido'   => 'required|string',
            'personal.rut'        => 'required|string|unique:personal,rut',
            'personal.id_empresa' => 'required|integer|exists:empresa,id_empresa',
            'usuario.username'    => 'required|string|unique:usuarios,nombre_usuario',
            'usuario.password'    => 'required|string|min:6',
            'roles'               => 'required|array|min:1',
        ]);

        try {
            $result = DB::transaction(function () use ($request) {
                
                $nuevoPersonal = Personal::create([
                    'nombre_personal'   => $request->input('personal.nombre'),
                    'apellido_personal' => $request->input('personal.apellido'),
                    'rut'               => $request->input('personal.rut'),
                    'correo'            => $request->personal['correo'] ?? null,
                    'id_empresa'        => $request->input('personal.id_empresa'),
                ]);

                $nuevoUsuario = User::create([
                    'nombre_usuario' => $request->input('usuario.username'),
                    'password'       => $request->input('usuario.password'), 
                    'id_personal'    => $nuevoPersonal->id_personal,
                ]);

                $rolesNombres = $request->input('roles');
                $rolesIds = TipoUsuario::whereIn('tipo_usuario', $rolesNombres) 
                                       ->pluck('id_tipo_usuario');
                
                $nuevoUsuario->roles()->attach($rolesIds);

                return $nuevoUsuario;
            });

            return response()->json([
                'success' => true, 
                'message' => 'Usuario creado exitosamente',
                'data' => $result
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false, 
                'message' => 'Error al guardar: ' . $e->getMessage()
            ], 500);
        }
    }

    // --- EDITAR USUARIO (CON PROTECCIÓN PARA ID 2) ---
    public function actualizarUsuario(Request $request, $id)
    {
        $usuario = User::with('personal')->find($id);

        if (!$usuario) {
            return response()->json(['success' => false, 'message' => 'Usuario no encontrado'], 404);
        }

        $personal = $usuario->personal;

        $request->validate([
            'nombre'   => 'required|string',
            'apellido' => 'required|string',
            'rut'      => 'required|string|unique:personal,rut,' . $personal->id_personal . ',id_personal',
            'correo'   => 'required|email', 
            'password' => 'nullable|string|min:6',
            'roles'    => 'nullable|array',
        ]);

        try {
            // === BLOQUE DE SEGURIDAD ===
            // Validamos antes de la transacción si intentan quitarle admin al usuario 2
            if ($usuario->id_usuario == 2 && $request->has('roles')) {
                $rolesNombres = $request->input('roles');
                
                // Verificamos si en la lista de nuevos roles viene 'Administrador'
                if (!in_array('Administrador', $rolesNombres)) {
                    return response()->json([
                        'success' => false, 
                        'message' => 'Acción denegada: No se puede quitar el rol de Administrador al usuario principal (ID 2).'
                    ], 403);
                }
            }
            // ===========================

            DB::transaction(function () use ($request, $usuario, $personal) {
                
                // 1. Actualizar Datos Personales
                $personal->update([
                    'nombre_personal'   => $request->input('nombre'),
                    'apellido_personal' => $request->input('apellido'),
                    'rut'               => $request->input('rut'),
                    'correo'            => $request->input('correo'),
                ]);

                // 2. Actualizar Password
                if ($request->filled('password')) {
                    $usuario->password = $request->input('password');
                    $usuario->save();
                }

                // 3. Actualizar Roles
                if ($request->has('roles')) {
                    $rolesNombres = $request->input('roles');
                    
                    $rolesIds = TipoUsuario::whereIn('tipo_usuario', $rolesNombres)
                                           ->pluck('id_tipo_usuario');

                    $usuario->roles()->sync($rolesIds);
                }
            });

            return response()->json([
                'success' => true, 
                'message' => 'Usuario y roles actualizados correctamente'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false, 
                'message' => 'Error al actualizar: ' . $e->getMessage()
            ], 500);
        }
    }
}