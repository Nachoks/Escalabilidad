<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Producto extends Model
{
    use HasFactory;

    protected $table = 'productos';
    protected $primaryKey = 'id_producto';
    public $timestamps = true;

    protected $fillable = [
        'id_proveedor',
        'codigo_producto',
        'nombre_producto',
        'marca',
    ];

    // Relación: Un producto pertenece a un proveedor
    public function proveedor()
    {
        return $this->belongsTo(Proveedor::class, 'id_proveedor', 'id_proveedor');
    }

    // Relación: Un producto tiene un registro de stock (1 a 1)
    public function stockGlobal()
    {
        return $this->hasOne(InventarioProducto::class, 'id_producto', 'id_producto');
    }
}
