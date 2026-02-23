<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class HojaTiempoDiaria extends Model
{
    use HasFactory;

    protected $table = 'hojas_tiempo_diarias';
    protected $primaryKey = 'id_hoja_diaria';

    protected $fillable = [
        'id_hoja_semana',
        'fecha',
        'lugar',
        'area',  
        'tipo_dia',
        'horario_inicio',
        'horario_fin',
        'viaje_horas',
    ];

    // Relación hacia el padre (Semana)
    public function semana()
    {
        return $this->belongsTo(HojaTiempoSemana::class, 'id_hoja_semana', 'id_hoja_semana');
    }

    // Relación hacia los nietos (Actividades)
    public function actividades()
    {
        return $this->hasMany(HojaTiempoActividad::class, 'id_hoja_diaria', 'id_hoja_diaria');
    }
}