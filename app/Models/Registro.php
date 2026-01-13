<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Registro extends Model
{
    use HasFactory;

    protected $table = 'registros';
    protected $primaryKey = 'id_registro_rendicion';
    public $timestamps = false;

    protected $fillable = [
        'id_rendicion',
        'fecha_pago',
        'monto_pagado',
        'nombre_original',
        'nombre_fisico',
        'peso_kb',
        'extension',
    ];

    public function rendicion()
    {
        return $this->belongsTo(Rendicion::class, 'id_rendicion', 'id_rendicion');
    }
}