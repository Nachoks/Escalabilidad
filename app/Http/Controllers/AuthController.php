<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
class AuthController extends Controller
{
    // LOGIN
    public function login(Request $request)
    {
        try { // <--- INICIO DE LA TRAMPA DE ERRORES
            
            // 1. Validar
            $request->validate([
                'nombre_usuario' => 'required|string',
                'password' => 'required|string',
            ]);

            // 2. Buscar Usuario
            $user = User::where('nombre_usuario', $request->nombre_usuario)->first();

            // 3. Verificar Password
            if (!$user || !Hash::check($request->password, $user->password)) {
                return response()->json([
                    'message' => 'Credenciales incorrectas'
                ], 401);
            }
            
            // 4. Verificar Estado
            if (!$user->estado) {
                return response()->json([
                    'message' => 'Su cuenta está deshabilitada.'
                ], 403); 
            }

            // 5. INTENTO DE CARGAR RELACIONES (Aquí suele fallar)
            try {
                $user->load(['personal.empresa', 'roles']);
            } catch (\Exception $e) {
                throw new \Exception("Error cargando relaciones (Tablas no encontradas): " . $e->getMessage());
            }

            // 6. INTENTO DE CREAR TOKEN (Aquí suele fallar si faltan tablas)
            try {
                $token = $user->createToken('movil')->plainTextToken;
            } catch (\Exception $e) {
                throw new \Exception("Error creando Token (Falta tabla personal_access_tokens): " . $e->getMessage());
            }

            // 7. RESPONDER
            return response()->json([
                'message' => 'Login exitoso',    
                'access_token' => $token,
                'token_type' => 'Bearer',
                'usuario' => $user, 
            ], 200);

        } catch (\Throwable $e) { // <--- CAPTURA DEL ERROR REAL
            return response()->json([
                'message' => 'ERROR DEL SISTEMA DETECTADO',
                'error_tecnico' => $e->getMessage(),
                'archivo' => $e->getFile(),
                'linea' => $e->getLine()
            ], 500);
        }
    }

    // LOGOUT
    public function logout(Request $request)
    {
        // 1. Capturamos al usuario antes de borrar el token
        $user = $request->user();

        // 2. LIMPIEZA DE NOTIFICACIONES (¡Esto es lo nuevo!)
        if ($user) {
            $user->onesignal_id = null; // Borramos el ID del celular
            $user->save(); // Guardamos el cambio en MySQL
        }

        // 3. Ahora sí, borramos el token de sesión (Lo que ya tenías)
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Sesión cerrada y notificaciones desactivadas'
        ], 200);
    }
    // ME (Perfil)
    public function me(Request $request)
    {
        $user = $request->user();
        
        // Aseguramos cargar toda la cadena de datos
        $user->load(['personal.empresa', 'roles']);

        return response()->json([
            'usuario' => $user // Enviamos el objeto completo estructura original
        ], 200);
    }

    // CAMBIAR CONTRASEÑA
    public function changePassword(Request $request)
    {
        // 1. Validar los datos que llegan
        $request->validate([
            'current_password' => 'required',
            'new_password' => 'required|string|min:6|confirmed', 
            // 'confirmed' busca automáticamente un campo 'new_password_confirmation'
        ]);

        // 2. Obtener el usuario autenticado
        $user = $request->user();

        // 3. Verificar que la contraseña actual sea correcta
        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'message' => 'La contraseña actual es incorrecta.'
            ], 400);
        }

        // 4. Actualizar la contraseña
        // Laravel se encarga de hashear automáticamente si está en el cast del modelo,
        // pero por seguridad explícita usamos Hash::make aquí también.
        $user->password = Hash::make($request->new_password);
        $user->save();

        return response()->json([
            'message' => 'Contraseña actualizada correctamente.'
        ], 200);
    }

    public function updateDeviceId(Request $request)
{
    $request->validate([
        'onesignal_id' => 'required|string'
    ]);

    $user = Auth::user();
    $user->onesignal_id = $request->onesignal_id;
    $user->save();

    return response()->json(['message' => 'Dispositivo vinculado correctamente']);
}
}