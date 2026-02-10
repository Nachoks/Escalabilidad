<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// --- TAREAS DE BACKUP MENSUAL ---

// 1. Generar Backup: El día 1 de cada mes a las 03:00 AM
Schedule::command('backup:run')->monthlyOn(1, '03:00');

// 2. Limpiar Viejos: El día 1 de cada mes a las 04:00 AM
// (Borra el backup del mismo mes del año pasado)
Schedule::command('backup:clean')->monthlyOn(1, '04:00');