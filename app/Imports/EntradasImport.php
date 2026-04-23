<?php

namespace App\Imports;

use App\Models\InventarioEntrada;
use App\Models\Producto;
use App\Models\User;
use Maatwebsite\Excel\Concerns\ToModel;
use Maatwebsite\Excel\Concerns\WithHeadingRow;
use Maatwebsite\Excel\Concerns\WithCustomCsvSettings;

class EntradasImport implements ToModel, WithHeadingRow, WithCustomCsvSettings
{
    public function model(array $row)
    {
        $serial = trim($row['serial'] ?? '');
        if (empty($serial) || empty($row['codigo'])) return null;

        // Evitar duplicados
        if (InventarioEntrada::where('serial', $serial)->exists()) {
            return null;
        }

        $producto = Producto::where('codigo_producto', trim($row['codigo']))->first();
        if (!$producto) return null;

        // 👇 Lógica correcta: Buscar en la tabla 'personal' o asignar al Admin
        $nombreResponsable = trim($row['responsable']);
        $nombres = explode(' ', $nombreResponsable);
        $primerNombre = $nombres[0];

        $responsable = User::whereHas('personal', function($q) use ($primerNombre) {
            $q->where('nombre_personal', 'LIKE', '%' . $primerNombre . '%');
        })->first();

        if (!$responsable) {
            $responsable = User::first(); 
        }

        return new InventarioEntrada([
            'id_producto'   => $producto->id_producto,
            'id_responsable'=> $responsable ? $responsable->id_usuario : 1,
            'oc_proveedor'  => $row['oc'] ?? 'S/N',
            'serial'        => $serial,
            'estado_serial' => 'Disponible', 
            'created_at'    => $row['fecha'] ?? now(),
        ]);
    }

    public function getCsvSettings(): array
    {
        return ['delimiter' => ';'];
    }
}
