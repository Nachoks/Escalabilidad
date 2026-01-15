<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
// --- IMPORTACIONES QUE FALTABAN ---
use App\Models\Gasto;     // <--- ESTA ES LA CLAVE DEL ERROR
use App\Models\Servicio;
use App\Models\User;
use App\Models\Registro;

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

    // --- ATRIBUTOS CALCULADOS (CAUSANTES DEL ERROR 500 SI FALLAN) ---

    public function getTotalGastadoAttribute()
    {
        // Validación de seguridad por si no se cargó la relación
        if (!$this->relationLoaded('gastos')) {
            return 0;
        }
        return $this->gastos->where('estado_gasto', '!=', 'Rechazado')->sum('monto');
    }

    public function getSaldoAttribute()
    {
        $asignado = $this->monto_entregado ?? 0;
        $gastado = $this->total_gastado; // Usa el atributo de arriba
        return $asignado - $gastado;
    }

    protected $appends = ['total_gastado', 'saldo'];
}