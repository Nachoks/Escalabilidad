<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Maatwebsite\Excel\Facades\Excel;
use App\Imports\ProductosImport;
use App\Imports\EntradasImport;
use App\Imports\SalidasImport;

class MigrarInventarioExcel extends Command
{
    protected $signature = 'inventario:migrar';
    protected $description = 'Migra los CSV de inventario a la base de datos en orden';

    public function handle()
    {
        $this->info('Iniciando migración de inventario...');

        $this->warn('1/3 Migrando Productos y Stock Base...');
        Excel::import(new ProductosImport, storage_path('app/productos.csv'));
        $this->info('¡Productos importados!');

        $this->warn('2/3 Migrando Entradas Históricas...');
        Excel::import(new EntradasImport, storage_path('app/entradas.csv'));
        $this->info('¡Entradas importadas!');

        $this->warn('3/3 Migrando Salidas Históricas y enlazando Entradas...');
        Excel::import(new SalidasImport, storage_path('app/salidas.csv'));
        $this->info('¡Salidas importadas!');

        $this->info('🚀 ¡MIGRACIÓN COMPLETADA CON ÉXITO! 🚀');
    }
}

