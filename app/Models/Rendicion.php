<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Gasto;
use App\Models\Servicio;
use App\Models\User;
use App\Models\Registro; // Mantenemos tu import

class Rendicion extends Model
{
    use HasFactory;

    // Respetamos tu configuración (Singular)
    protected $table = 'rendicion'; 
    protected $primaryKey = 'id_rendicion';
    public $timestamps = false; 
    protected $appends = ['total_gastado'];

    protected $fillable = [
        'fecha',
        'proposito',
        'monto_entregado',
        'estado',
        'centro_costo',
        'id_servicio',
        'id_usuario',
    ];


    // --- RELACIONES (Tus relaciones intactas) ---

    public function servicio()
    {
        return $this->belongsTo(Servicio::class, 'id_servicio', 'id_servicio');
    }

    public function usuario()
    {
        return $this->belongsTo(User::class, 'id_usuario', 'id_usuario'); // Asumo que id_usuario es la PK en User según tu código
    }

    public function gastos()
    {
        return $this->hasMany(Gasto::class, 'id_rendicion', 'id_rendicion');
    }

    public function registros()
    {
        return $this->hasMany(Registro::class, 'id_rendicion', 'id_rendicion');
    }

    // --- CORRECCIÓN TÉCNICA AQUÍ ---

    public function getTotalGastadoAttribute()
    {
        // 1. PRIORIDAD: Si usamos withSum, Laravel guarda el valor en 'gastos_sum_monto'
        if (isset($this->attributes['gastos_sum_monto'])) {
            return (int) $this->attributes['gastos_sum_monto'];
        }

        // 2. FALLBACK: Si cargamos la relación completa (ej. en el detalle)
        if ($this->relationLoaded('gastos')) {
            return $this->gastos->sum('monto');
        }

        return 0;
    }

    public function getSaldoAttribute()
    {
        $asignado = $this->monto_entregado ?? 0;
        
        // Usamos la lógica corregida de arriba
        $gastado = $this->total_gastado; 
        
        return $asignado - $gastado;
    }
}