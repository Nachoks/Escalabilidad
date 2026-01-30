<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class HasGuiaArchivo extends Model
{
    use HasFactory;

    protected $table = 'has_guia_archivos';
    protected $primaryKey = 'id_archivo';
    public $timestamps = false;

    protected $fillable = [
        'id_has_guia',
        'nombre_original',
        'nombre_fisico',
        'ruta_relativa',
        'extension',
        'peso_kb'
    ];

    // Relación Hacia Arriba (Padre)
    public function guia()
    {
        return $this->belongsTo(HasGuia::class, 'id_has_guia', 'id_has_guia');
    }
}