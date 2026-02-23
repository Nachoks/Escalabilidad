<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\file;

Route::get('/{any}', function () {
    $path = public_path('index.html');

    if (!File::exists($path)) {
        abort(404, 'Archivo no encontrado');

    }
    return File::get($path);
})->where('any', '.*');

