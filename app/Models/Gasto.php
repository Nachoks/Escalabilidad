<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Gasto extends Model
{
    use HasFactory;

    protected $table = 'gasto';
    protected $primaryKey = 'id_gasto';
    public $timestamps = false; // La migración no tiene created_at/updated_at

    protected $fillable = [
        'fecha',
        'num_documento',
        'monto',
        'estado_gasto',
        'comentario_validador',
        'tipo_documento', // Nuevo campo texto
        'detalle',        // Nuevo campo texto
        'id_rendicion',
        'id_validador',
        // 'categoria_otro' y 'proveedor' ya no están, así que no se agregan
    ];

    // --- RELACIONES ---

    // Un Gasto pertenece a una Rendición
    public function rendicion()
    {
        return $this->belongsTo(Rendicion::class, 'id_rendicion', 'id_rendicion');
    }

    // Un Gasto tiene muchos Archivos (Evidencia)
    public function archivos()
    {
        return $this->hasMany(GastoArchivo::class, 'id_gasto', 'id_gasto');
    }

    // Un Gasto puede ser validado por un Usuario (Opcional)
    public function validador()
    {
        return $this->belongsTo(User::class, 'id_validador', 'id_usuario');
    }
}