<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ContactoProveedor extends Model
{
    use HasFactory;

    protected $table = 'contactos_proveedores';
    protected $primaryKey = 'id_contacto';
    public $timestamps = true;

    protected $fillable = [
        'id_proveedor',
        'nombre_contacto',
        'numero_contacto',
        'correo_contacto',
    ];

    public function proveedor()
    {
        return $this->belongsTo(Proveedor::class, 'id_proveedor', 'id_proveedor');
    }
}
