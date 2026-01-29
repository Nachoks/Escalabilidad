<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use App\Models\User;


class OneSignalService
{
    public static function enviar(array $userIds, string $titulo, string $mensaje, array $data = [])
    {
        // 1. Filtrar usuarios con ID de OneSignal
        $destinatarios = User::whereIn('id_usuario', $userIds)
                             ->whereNotNull('onesignal_id')
                             ->pluck('onesignal_id')
                             ->toArray();

        if (empty($destinatarios)) {
            Log::info("OneSignal: Sin destinatarios válidos.");
            return false;
        }

        try {
            // 2. Enviar Petición (Con bypass SSL para tu NAS)
            $response = Http::withoutVerifying()
                ->withHeaders([
                    'Content-Type'  => 'application/json; charset=utf-8',
                    'Authorization' => 'Basic ' . env('ONESIGNAL_REST_API_KEY')
                ])->post('https://onesignal.com/api/v1/notifications', [
                    'app_id'             => env('ONESIGNAL_APP_ID'),
                    'include_player_ids' => $destinatarios,
                    'headings'           => ['en' => $titulo],
                    'contents'           => ['en' => $mensaje],
                    'data'               => $data,
                    'small_icon'         => 'ic_stat_onesignal_default',
                    'android_channel_id' => 'onesignal_default_channel' // Importante para Android
                ]);

            if ($response->failed()) {
                Log::error("OneSignal Falló: " . $response->body());
                return false;
            }

            Log::info("OneSignal Enviado a " . count($destinatarios) . " usuarios.");
            return true;

        } catch (\Exception $e) {
            Log::error("OneSignal Exception: " . $e->getMessage());
            return false;
        }
    }
}