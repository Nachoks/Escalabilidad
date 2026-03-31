<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Proveedor extends Model
{
    use HasFactory;

    protected $table = 'proveedores';
    protected $primaryKey = 'id_proveedor';
    public $timestamps = true;

    protected $fillable = [
        'nombre_proveedor',
    ];

    // Un proveedor tiene muchos productos
    public function productos()
    {
        return $this->hasMany(Producto::class, 'id_proveedor', 'id_proveedor');
    }
 
    // Un proveedor tiene muchos contactos 
    public function contactos()
    {
        return $this->hasMany(ContactoProveedor::class, 'id_proveedor', 'id_proveedor');
    }
}
