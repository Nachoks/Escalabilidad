<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Rendicion extends Model
{
    use HasFactory;

    protected $table = 'rendicion';
    protected $primaryKey = 'id_rendicion';
    public $timestamps = false;

    protected $fillable = [
        'fecha',
        'proposito',
        'monto_entregado',
        'estado',
        'centro_costo',
        'id_servicio',
        'id_usuario',
    ];

    // Relaciones
    public function servicio()
    {
        return $this->belongsTo(Servicio::class, 'id_servicio', 'id_servicio');
    }

    public function usuario()
    {
        // Asumiendo que usas el modelo User por defecto de Laravel
        return $this->belongsTo(User::class, 'id_usuario', 'id_usuario');
    }

    public function gastos()
    {
        return $this->hasMany(Gasto::class, 'id_rendicion', 'id_rendicion');
    }

    public function registros()
    {
        return $this->hasMany(Registro::class, 'id_rendicion', 'id_rendicion');
    }

    public function getTotalGastadoAttribute()
    {
        return $this->gastos->where('estado_gasto', '!=', 'Rechazado')->sum('monto');
    }

    // 2. Saldo Final: (Lo que me dieron) - (Lo que gasté)
    public function getSaldoAttribute()
    {
        $asignado = $this->monto_entregado ?? 0;
        $gastado = $this->total_gastado; 

        return $asignado - $gastado;
    }

    // IMPORTANTE: Esto hace que viajen en el JSON
    protected $appends = ['total_gastado', 'saldo'];
}