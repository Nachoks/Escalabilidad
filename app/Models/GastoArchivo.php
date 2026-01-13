<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class GastoArchivo extends Model
{
    use HasFactory;

    protected $table = 'gasto_archivo';
    protected $primaryKey = 'id_gasto_archivo';
    
    // Configuración especial: Solo created_at
    public $timestamps = true;
    const UPDATED_AT = null; 

    protected $fillable = [
        'id_gasto',
        'nombre_original',
        'nombre_fisico',
        'ruta_relativa',
        'extension',
        'peso_kb',
        'id_validador',
    ];

    public function gasto()
    {
        return $this->belongsTo(Gasto::class, 'id_gasto', 'id_gasto');
    }

    public function validador()
    {
        return $this->belongsTo(User::class, 'id_validador', 'id_usuario');
    }
}