<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AreaEmpresa extends Model
{
    use HasFactory;

    // Nombre exacto de la tabla en la migración
    protected $table = 'areas_empresa'; 
    protected $primaryKey = 'id_area';

    protected $fillable = ['id_empresa', 'nombre_area', 'codigo_area'];

    // Relación inversa: Pertenece a una empresa
    public function empresa()
    {
        return $this->belongsTo(Empresa::class, 'id_empresa', 'id_empresa');
    }
}