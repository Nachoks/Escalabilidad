<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class HasGuia extends Model
{
    use HasFactory;

    protected $table = 'has_guia';
    protected $primaryKey = 'id_has_guia';
    public $timestamps = false;

    protected $fillable = [
        'cod_has_guia',
        'id_servicio',
    ];

    public function servicio()
    {
        return $this->belongsTo(Servicio::class, 'id_servicio', 'id_servicio');
    }
}