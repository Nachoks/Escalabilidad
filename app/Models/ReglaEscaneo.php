<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;


class ReglaEscaneo extends Model
{
    use HasFactory;


    // Vinculamos explícitamente la tabla y la llave primaria
    protected $table = 'reglas_escaneo';
    protected $primaryKey = 'id_regla';
    public $timestamps = true;


    // Definimos qué campos se pueden llenar masivamente
    protected $fillable = [
        'nombre_marca',
        'prefijo_codigo',
        'prefijo_serie',
        'separador_ignorar',
    ];
}



