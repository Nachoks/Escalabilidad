<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Servicio extends Model
{
    use HasFactory;

    protected $table = 'servicio';
    protected $primaryKey = 'id_servicio';
    public $timestamps = false; 

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

    // --- RELACIONES ---

    public function cliente()
    {
        return $this->belongsTo(Cliente::class, 'id_cliente', 'id_cliente');
    }

    public function area()
    {
        return $this->belongsTo(AreaEmpresa::class, 'id_area', 'id_area');
    }

    // CORRECCIÓN 1: Renombrado a 'ocs' para coincidir con el Frontend
    public function ocs()
    {
        return $this->hasMany(OcCliente::class, 'id_servicio', 'id_servicio');
    }

    // CORRECCIÓN 2: Relación 'A través de' para llegar a las guías sin la columna id_servicio
    // Servicio -> tiene OCs -> tienen Guías
    public function guias()
    {
        return $this->hasManyThrough(
            HasGuia::class,      // Modelo Destino
            OcCliente::class,    // Modelo Intermedio
            'id_servicio',       // FK en tabla intermedia (oc_cliente)
            'id_oc_cliente',     // FK en tabla destino (has_guia)
            'id_servicio',       // PK local (servicio)
            'id_oc_cliente'      // PK intermedia (oc_cliente)
        );
    }

    public function rendiciones()
    {
        return $this->hasMany(Rendicion::class, 'id_servicio', 'id_servicio');
    }
}