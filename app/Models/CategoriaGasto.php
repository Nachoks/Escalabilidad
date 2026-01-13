<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CategoriaGasto extends Model
{
    protected $table = 'categoria_gasto';
    protected $primaryKey = 'id_categoria_gasto';
    public $timestamps = false;

    protected $fillable = ['nombre_gasto'];
}