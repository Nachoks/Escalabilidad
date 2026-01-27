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
    public $timestamps = false; 
    
    // AQUÍ ESTÁ LA CLAVE: Pedimos que se adjunte 'ruta_comprobante' al JSON
    protected $appends = ['total_gastado', 'ruta_comprobante'];
    
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

    // Agregamos esta relación helper 'hasOne' para ser más precisos (trae el último pago)
    public function registroPago()
    {
        return $this->hasOne(Registro::class, 'id_rendicion', 'id_rendicion')->latest();
    }

    // --- ATTRIBUTES (La Magia) ---

    /**
     * ESTA ES LA FUNCIÓN QUE TE FALTABA
     * Laravel busca get[NombreEnAppends]Attribute
     */
    public function getRutaComprobanteAttribute()
    {
        // 1. Intentamos obtenerlo de la relación singular si fue cargada
        if ($this->relationLoaded('registroPago') && $this->registroPago) {
            return $this->registroPago->ruta_relativa;
        }

        // 2. Si no, intentamos sacarlo de la colección 'registros'
        // (Tomamos el primero que tenga ruta, asumiendo que es el pago)
        if ($this->registros->isNotEmpty()) {
            return $this->registros->first()->ruta_relativa;
        }

        // 3. Si no hay registros, retornamos null
        return null;
    }

    public function getTotalGastadoAttribute()
    {
        // 1. PRIORIDAD: Si usamos withSum
        if (isset($this->attributes['gastos_sum_monto'])) {
            return (int) $this->attributes['gastos_sum_monto'];
        }

        // 2. FALLBACK: Si cargamos la relación completa
        if ($this->relationLoaded('gastos')) {
            return $this->gastos->sum('monto');
        }

        return 0;
    }

    public function getSaldoAttribute()
    {
        $asignado = $this->monto_entregado ?? 0;
        $gastado = $this->total_gastado; 
        
        return $asignado - $gastado;
    }
}