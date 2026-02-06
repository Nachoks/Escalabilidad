<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use App\Models\User;

class OneSignalService
{
    /**
     * Enviar notificación Push a usuarios específicos mediante OneSignal.
     *
     * @param array  $userIds Lista de IDs de la tabla users (id_usuario)
     * @param string $titulo  Título de la notificación
     * @param string $mensaje Cuerpo del mensaje
     * @param array  $data    Datos adicionales (payload) para manejar en la app
     * @return bool
     */
    public static function enviar(array $userIds, string $titulo, string $mensaje, array $data = [])
    {
        // 1. Filtrar usuarios que tengan un Player ID de OneSignal válido
        // Aseguramos que 'onesignal_id' no sea nulo ni vacío
        $destinatarios = User::whereIn('id_usuario', $userIds)
                             ->whereNotNull('onesignal_id')
                             ->where('onesignal_id', '!=', '')
                             ->pluck('onesignal_id')
                             ->toArray();

        // Si no hay a quién enviar, terminamos temprano
        if (empty($destinatarios)) {
            Log::warning("OneSignal: Se intentó enviar una notificación pero no se encontraron usuarios con 'onesignal_id' válido en la lista proporcionada.");
            return false;
        }

        try {
            // 2. Preparar el cuerpo de la solicitud
            $payload = [
                'app_id'             => env('ONESIGNAL_APP_ID'),
                'include_player_ids' => $destinatarios,
                
                // Definimos idioma inglés y español para asegurar visibilidad
                'headings'           => ['en' => $titulo, 'es' => $titulo],
                'contents'           => ['en' => $mensaje, 'es' => $mensaje],
                
                'data'               => $data,
                'small_icon'         => 'ic_stat_onesignal_default', // Asegúrate de tener este recurso en Android/App/src/main/res
                
                // 'android_channel_id' => 'onesignal_default_channel' 
                // COMENTADO: Esto suele causar problemas si el canal no está creado explícitamente en Flutter.
                // Al comentarlo, OneSignal usará el canal por defecto (fcm_fallback_notification_channel) que siempre funciona.
            ];

            // 3. Enviar Petición a OneSignal
            // Usamos withoutVerifying() solo si tu servidor tiene problemas con certificados SSL salientes (común en entornos locales/dev)
            $response = Http::withoutVerifying()
                ->withHeaders([
                    'Content-Type'  => 'application/json; charset=utf-8',
                    'Authorization' => 'Basic ' . env('ONESIGNAL_REST_API_KEY')
                ])->post('https://onesignal.com/api/v1/notifications', $payload);

            // 4. Analizar la Respuesta
            $responseBody = $response->json();

            // Loguear la respuesta completa para depuración (puedes comentarlo en producción)
            Log::info("OneSignal Response: " . $response->body());

            // A) Verificar errores lógicos de OneSignal (ej: "All included players are not subscribed")
            // OneSignal a veces devuelve 200 OK pero con un array de 'errors' dentro.
            if (isset($responseBody['errors'])) {
                Log::error("OneSignal Error Lógico: " . json_encode($responseBody['errors']));
                return false;
            }

            // B) Verificar fallos de conexión HTTP (400, 401, 500)
            if ($response->failed()) {
                Log::error("OneSignal Falló HTTP (" . $response->status() . "): " . $response->body());
                return false;
            }

            // Éxito
            Log::info("OneSignal Enviado correctamente a " . count($destinatarios) . " dispositivos (recipients: " . ($responseBody['recipients'] ?? 0) . ")");
            return true;

        } catch (\Exception $e) {
            Log::error("OneSignal Exception Crítica: " . $e->getMessage());
            return false;
        }
    }
}