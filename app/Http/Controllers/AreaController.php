<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\AreaEmpresa;

class AreaController extends Controller
{
    // Listar todas las áreas disponibles
    public function index()
    {
        // Retornamos ID y Nombre (lo que necesita el dropdown)
        return response()->json(AreaEmpresa::all(), 200);
    }
}