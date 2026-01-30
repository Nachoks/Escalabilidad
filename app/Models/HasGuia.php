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
        'id_oc_cliente'
    ];

    // Relación Inversa: Pertenece a una OC
    public function oc()
    {
        return $this->belongsTo(OcCliente::class, 'id_oc_cliente', 'id_oc_cliente');
    }

    // 👇 ESTA ES LA FUNCIÓN QUE TE FALTABA 👇
    public function archivos()
    {
        return $this->hasMany(HasGuiaArchivo::class, 'id_has_guia', 'id_has_guia');
    }
}