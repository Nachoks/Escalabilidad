<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class HojaTiempoSemana extends Model
{
    use HasFactory;

    // 1. Especificar nombre de tabla y llave primaria personalizada
    protected $table = 'hojas_tiempo_semanas';
    protected $primaryKey = 'id_hoja_semana';

    // 2. Campos permitidos para guardar masivamente
    protected $fillable = [
        'id_usuario',
        'id_servicio',
        'id_oc_cliente',
        'centro_costo',
        'numero_semana',
        'fecha_inicio',
        'fecha_fin',
        'estado'
    ];

    // ================= RELACIONES HACIA ARRIBA =================

    public function usuario()
    {
        // NOTA: Cambia "User::class" por "Personal::class" o el modelo que uses para tus usuarios
        return $this->belongsTo(User::class, 'id_usuario', 'id_usuario');
    }

    public function servicio()
    {
        return $this->belongsTo(Servicio::class, 'id_servicio', 'id_servicio');
    }

    public function ocCliente()
    {
        return $this->belongsTo(OcCliente::class, 'id_oc_cliente', 'id_oc_cliente');
    }

    // ================= RELACIONES HACIA ABAJO =================

    public function dias()
    {
        // Una semana tiene 7 días
        return $this->hasMany(HojaTiempoDiaria::class, 'id_hoja_semana', 'id_hoja_semana');
    }
}