<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Gasto;
use App\Models\Servicio;
use App\Models\User;
use App\Models\Registro;

class Rendicion extends Model
{
    use HasFactory;

    protected $table = 'rendicion';
    protected $primaryKey = 'id_rendicion';
    public $timestamps = false; // Asumo que no usas created_at/updated_at

    protected $fillable = [
        'fecha',
        'proposito',
        'monto_entregado',
        'estado',
        'centro_costo',
        'id_servicio',
        'id_usuario',
    ];

    // --- RELACIONES ---

    public function servicio()
    {
        return $this->belongsTo(Servicio::class, 'id_servicio', 'id_servicio');
    }

    public function usuario()
    {
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

    // --- ATRIBUTOS CALCULADOS (CORREGIDOS) ---

    // Le decimos a Laravel que siempre agregue estos campos al JSON
    protected $appends = ['total_gastado', 'saldo'];

    public function getTotalGastadoAttribute()
    {
        // CORRECCIÓN IMPORTANTE:
        // Quitamos el 'if relationLoaded'. Ahora accedemos directo a $this->gastos.
        // Laravel es listo: si no están cargados, hará la consulta automáticamente para sumarlos.
        // Además, filtramos para no sumar los rechazados (buena práctica).
        
        return $this->gastos->where('estado_gasto', '!=', 'Rechazado')->sum('monto');
    }

    public function getSaldoAttribute()
    {
        $asignado = $this->monto_entregado ?? 0;
        
        // Accedemos al atributo mágico que creamos arriba
        $gastado = $this->total_gastado; 
        
        return $asignado - $gastado;
    }
}