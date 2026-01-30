<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OcCliente extends Model
{
    use HasFactory;

    protected $table = 'oc_cliente'; // <--- ESTO ES VITAL
    protected $primaryKey = 'id_oc_cliente';
    public $timestamps = false;

    protected $fillable = [
        'cod_oc_cliente',
        'id_servicio',
    ];

    public function servicio()
    {
        return $this->belongsTo(Servicio::class, 'id_servicio', 'id_servicio');
    }

    public function guias()
    {
        return $this->hasMany(HasGuia::class, 'id_oc_cliente', 'id_oc_cliente');
    }
}