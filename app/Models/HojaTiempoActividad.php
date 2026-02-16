<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class HojaTiempoActividad extends Model
{
    use HasFactory;

    protected $table = 'hojas_tiempo_actividades';
    protected $primaryKey = 'id_actividad';

    protected $fillable = [
        'id_hoja_diaria',
        'hora_inicio',
        'hora_fin',
        'descripcion',
        'horas_habiles',
        'horas_no_habiles',
        'horas_festivas',
    ];

    // Relación hacia el padre (Día)
    public function dia()
    {
        return $this->belongsTo(HojaTiempoDiaria::class, 'id_hoja_diaria', 'id_hoja_diaria');
    }
}