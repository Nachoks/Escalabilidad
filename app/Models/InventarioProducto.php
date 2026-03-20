<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class InventarioProducto extends Model
{
    use HasFactory;

    protected $table = 'inventario_productos';
    protected $primaryKey = 'id_inventario';
    public $timestamps = true;

    protected $fillable = [
        'id_producto',
        'stock_actual',
        'stock_minimo',
    ];

    // Relación: Este registro pertenece a un producto del catálogo
    public function producto()
    {
        return $this->belongsTo(Producto::class, 'id_producto', 'id_producto');
    }
}
