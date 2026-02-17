<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class HojaTiempoSemana extends Model
{
    use HasFactory;

    protected $table = 'hojas_tiempo_semanas';
    protected $primaryKey = 'id_hoja_semana';

    protected $fillable = [
        'id_usuario',
        'id_servicio',
        'id_oc_cliente',
        'numero_hct',
        'nombre_comprobante',
        'centro_costo',
        'numero_semana',
        'fecha_inicio',
        'fecha_fin',
        'estado',
        'observacion',
    ];

    // Relación hacia los días (1 Semana tiene 7 Días)
    public function dias()
    {
        return $this->hasMany(HojaTiempoDiaria::class, 'id_hoja_semana', 'id_hoja_semana');
    }

    // Relación hacia el Servicio (Para poder traer el nombre y correlativo fácilmente)
    public function servicio()
    {
        return $this->belongsTo(Servicio::class, 'id_servicio', 'id_servicio');
    }

    // Relación hacia la OC
    public function ocCliente()
    {
        return $this->belongsTo(OcCliente::class, 'id_oc_cliente', 'id_oc_cliente');
    }
}