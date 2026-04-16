<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class InventarioSalida extends Model
{
    use HasFactory;

    protected $table = 'inventario_salidas';
    protected $primaryKey = 'id_salida';
    public $timestamps = true;

    protected $fillable = [
        'id_entrada',
        'id_producto',
        'id_cliente',
        'id_responsable',
        'oc_cliente',
        'serial',
    ];

    // Relación: De qué entrada física proviene esta salida
    public function entradaOriginal()
    {
        return $this->belongsTo(InventarioEntrada::class, 'id_entrada', 'id_entrada');
    }

    // Relación: Qué producto es
    public function producto()
    {
        return $this->belongsTo(Producto::class, 'id_producto', 'id_producto');
    }

    // Relación: A qué cliente se le entregó
    public function cliente()
    {
        return $this->belongsTo(Cliente::class, 'id_cliente', 'id_cliente');
    }

    // Relación: Quién despachó el equipo
    public function responsable()
    {
        return $this->belongsTo(User::class, 'id_responsable', 'id_usuario');
    }

    public function ordenCompra()
    {
        return $this->belongsTo(OcCliente::class, 'oc_cliente', 'cod_oc_cliente');
    }
}
