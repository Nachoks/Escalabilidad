<?php

namespace App\Imports;

use App\Models\InventarioSalida;
use App\Models\InventarioEntrada;
use App\Models\Producto;
use App\Models\Cliente;
use App\Models\User;
use Maatwebsite\Excel\Concerns\ToModel;
use Maatwebsite\Excel\Concerns\WithHeadingRow;
use Maatwebsite\Excel\Concerns\WithCustomCsvSettings;

class SalidasImport implements ToModel, WithHeadingRow, WithCustomCsvSettings
{
    public function model(array $row)
    {
        $serial = trim($row['serial'] ?? '');
        if (empty($serial)) return null;

        // Evitar duplicados
        if (InventarioSalida::where('serial', $serial)->exists()) {
            return null;
        }

        $producto = Producto::where('codigo_producto', trim($row['codigo']))->first();
        $idProducto = $producto ? $producto->id_producto : 1; 

        $cliente = Cliente::firstOrCreate(
            ['nombre_cliente' => trim($row['cliente'] ?? 'Cliente Genérico')]
        );

        $nombreResponsable = trim($row['responsable']);
        $nombres = explode(' ', $nombreResponsable);
        $primerNombre = $nombres[0];

        $responsable = User::whereHas('personal', function($q) use ($primerNombre) {
            $q->where('nombre_personal', 'LIKE', '%' . $primerNombre . '%');
        })->first();

        if (!$responsable) {
            $responsable = User::first(); 
        }

        // Buscar la entrada original
        $entrada = InventarioEntrada::where('serial', $serial)->first();
        
        if ($entrada) {
            $entrada->update(['estado_serial' => 'Entregado']);
        } else {
            // 1. Creamos la entrada fantasma
            InventarioEntrada::create([
                'id_producto'   => $idProducto,
                'id_responsable'=> $responsable ? $responsable->id_usuario : 1,
                'oc_proveedor'  => 'MIGRACION_FALTANTE', 
                'serial'        => $serial,
                'estado_serial' => 'Entregado', 
                'created_at'    => $row['fecha'] ?? now(),
            ]);
            
            // 👇 LA SOLUCIÓN: Volvemos a consultar la base de datos para obligar a Laravel a darnos el id_entrada real
            $entrada = InventarioEntrada::where('serial', $serial)->first();
        }

        return new InventarioSalida([
            'id_entrada'    => $entrada->id_entrada, // ¡Ahora esto es 100% seguro que no será null!
            'id_producto'   => $idProducto,
            'id_cliente'    => $cliente->id_cliente, 
            'id_responsable'=> $responsable ? $responsable->id_usuario : 1,
            'oc_cliente'    => $row['oc'] ?? 'S/N',
            'serial'        => $serial,
            'created_at'    => $row['fecha'] ?? now(),
        ]);
    }

    public function getCsvSettings(): array
    {
        return ['delimiter' => ';'];
    }
}
