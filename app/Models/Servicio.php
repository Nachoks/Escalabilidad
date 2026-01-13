<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Servicio extends Model
{
    use HasFactory;

    protected $table = 'servicio';
    protected $primaryKey = 'id_servicio';
    public $timestamps = false; // No incluiste timestamps en la migración

    protected $fillable = [
        'nombre_servicio',
        'id_cliente',
        'id_area',
        'centro_costo',
        'fecha_inicio',
        'fecha_termino',
        'estado_servicio',
        'facturacion',
        'correlativo',
    ];

    // Relaciones
    public function cliente()
    {
        return $this->belongsTo(Cliente::class, 'id_cliente', 'id_cliente');
    }

    public function ordenesCompra()
    {
        return $this->hasMany(OcCliente::class, 'id_servicio', 'id_servicio');
    }

    public function guias()
    {
        return $this->hasMany(HasGuia::class, 'id_servicio', 'id_servicio');
    }

    public function rendiciones()
    {
        return $this->hasMany(Rendicion::class, 'id_servicio', 'id_servicio');
    }

    public function area()
    {
        return $this->belongsTo(AreaEmpresa::class, 'id_area', 'id_area');
    }
}