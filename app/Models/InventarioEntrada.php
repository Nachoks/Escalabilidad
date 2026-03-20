<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class InventarioEntrada extends Model
{
    use HasFactory;

    protected $table = 'inventario_entradas';
    protected $primaryKey = 'id_entrada';
    public $timestamps = true;

    protected $fillable = [
        'id_producto',
        'id_responsable',
        'oc_proveedor',
        'serial',
        'estado_serial',
    ];

    // Relación: El equipo ingresado es de un modelo específico de producto
    public function producto()
    {
        return $this->belongsTo(Producto::class, 'id_producto', 'id_producto');
    }

    // Relación: Quién (Usuario) ingresó el equipo
    // Nota: Amarramos 'id_responsable' con tu llave 'id_usuario' del User.php
    public function responsable()
    {
        return $this->belongsTo(User::class, 'id_responsable', 'id_usuario');
    }

    // Relación: Si este equipo ya salió, podemos saber a dónde
    public function salida()
    {
        return $this->hasOne(InventarioSalida::class, 'id_entrada', 'id_entrada');
    }
}
