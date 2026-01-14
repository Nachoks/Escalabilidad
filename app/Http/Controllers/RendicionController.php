<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Rendicion;
use App\Models\Servicio;

class RendicionController extends Controller
{
    // 1. CREAR BORRADOR (Sin fecha todavía)
    public function store(Request $request)
    {
        $request->validate([
            'id_servicio' => 'required|exists:servicio,id_servicio',
            'proposito'   => 'required|string|max:255',
            // 'fecha' => YA NO SE PIDE AQUÍ
            'monto_entregado' => 'nullable|integer',
        ]);

        $servicio = Servicio::findOrFail($request->id_servicio);

        $rendicion = Rendicion::create([
            'id_usuario'      => Auth::id(),
            'id_servicio'     => $request->id_servicio,
            'fecha'           => null, // <-- Nace nula
            'proposito'       => $request->proposito,
            'monto_entregado' => $request->monto_entregado ?? 0,
            'estado'          => 'Borrador',
            'centro_costo'    => $servicio->centro_costo,
        ]);

        return response()->json([
            'success' => true, 
            'data' => $rendicion
        ], 201);
    }

    // 2. ENVIAR A REVISIÓN (Aquí se fija la fecha)
    public function enviar($id)
    {
        $rendicion = Rendicion::findOrFail($id);

        if ($rendicion->id_usuario != Auth::id()) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        // Validar que tenga gastos (opcional, buena práctica)
        if ($rendicion->gastos()->count() == 0) {
            return response()->json(['message' => 'La rendición no tiene gastos'], 400);
        }

        $rendicion->update([
            'estado' => 'Pendiente de Validación',
            'fecha'  => now() // <-- AQUÍ SE GUARDA LA FECHA REAL
        ]);

        return response()->json(['success' => true, 'message' => 'Rendición enviada']);
    }

    // ... (Mantén tus métodos misRendiciones y show iguales) ...
    public function misRendiciones()
    {
        $rendiciones = Rendicion::where('id_usuario', Auth::id())
                        ->with(['servicio:id_servicio,nombre_servicio,centro_costo'])
                        ->orderByDesc('id_rendicion') // Ordenar por ID ya que fecha puede ser null
                        ->get();

        return response()->json($rendiciones);
    }

    public function show($id)
    {
        $rendicion = Rendicion::with(['gastos', 'servicio'])->findOrFail($id);
        if ($rendicion->id_usuario != Auth::id()) {
            return response()->json(['message' => 'No autorizado'], 403);
        }
        return response()->json($rendicion);
    }
}