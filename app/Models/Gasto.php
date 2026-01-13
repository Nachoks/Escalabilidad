<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Gasto extends Model
{
    use HasFactory;

    protected $table = 'gasto';
    protected $primaryKey = 'id_gasto';
    public $timestamps = false;

    protected $fillable = [
        'fecha',
        'num_documento',
        'monto',
        'estado_gasto',
        'comentario_validador',
        'id_validador',
        'categoria_otro',
        'id_rendicion',
        'id_tipo_documento',
        'id_categoria_gasto',
    ];

    // Relaciones
    public function rendicion()
    {
        return $this->belongsTo(Rendicion::class, 'id_rendicion', 'id_rendicion');
    }

    public function tipoDocumento()
    {
        return $this->belongsTo(TipoDocumento::class, 'id_tipo_documento', 'id_tipo_documento');
    }

    public function categoriaGasto()
    {
        return $this->belongsTo(CategoriaGasto::class, 'id_categoria_gasto', 'id_categoria_gasto');
    }

    public function validador()
    {
        return $this->belongsTo(User::class, 'id_validador', 'id_usuario');
    }

    public function archivos()
    {
        return $this->hasMany(GastoArchivo::class, 'id_gasto', 'id_gasto');
    }
}