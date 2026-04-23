<?php

namespace App\Imports;

use App\Models\Producto;
use App\Models\Proveedor;
use App\Models\InventarioProducto;
use Maatwebsite\Excel\Concerns\ToModel;
use Maatwebsite\Excel\Concerns\WithHeadingRow;
use Maatwebsite\Excel\Concerns\WithCustomCsvSettings;

class ProductosImport implements ToModel, WithHeadingRow, WithCustomCsvSettings
{
    public function model(array $row)
    {
        // Si la fila no tiene código, la saltamos
        if (empty($row['codigo'])) return null;

        // 1. Creamos un proveedor temporal para la migración
        $proveedor = Proveedor::firstOrCreate(
            ['nombre_proveedor' => 'Proveedor Migración'],
            ['correo_contacto' => 'migracion@iaa.cl']
        );

        // 2. Creamos el Producto en el catálogo
        $producto = Producto::firstOrCreate(
            ['codigo_producto' => trim($row['codigo'])],
            [
                'nombre_producto' => $row['nombre'] ?? 'Sin Nombre',
                'marca'           => 'Desconocida',
                'id_proveedor'    => $proveedor->id_proveedor,
            ]
        );

        // 3. Establecemos su Stock Global en la tabla de inventario
        InventarioProducto::updateOrCreate(
            ['id_producto' => $producto->id_producto],
            [
                'stock_actual' => (int) ($row['stock'] ?? 0),
                'stock_minimo' => (int) ($row['stock_minimo'] ?? 0),
            ]
        );

        return $producto;
    }

    // Configuración para leer punto y coma
    public function getCsvSettings(): array
    {
        return [
            'delimiter' => ';'
        ];
    }
}
