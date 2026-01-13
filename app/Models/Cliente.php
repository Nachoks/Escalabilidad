<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Cliente extends Model
{
    use HasFactory;

    protected $table = 'cliente';
    protected $primaryKey = 'id_cliente';
    
    // Como en esta migración SÍ pusiste timestamps(), dejamos esto en true (por defecto)
    public $timestamps = true; 

    protected $fillable = [
        'cod_cliente',
        'nombre_cliente',
        'correo_representante',
        'nombre_representante',
    ];

    // Relaciones
    public function servicios()
    {
        return $this->hasMany(Servicio::class, 'id_cliente', 'id_cliente');
    }
}