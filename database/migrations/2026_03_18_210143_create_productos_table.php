<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('productos', function (Blueprint $table) {
            $table->id('id_producto');
            
            $table->foreignId('id_proveedor')
                  ->constrained('proveedores', 'id_proveedor')
                  ->onDelete('restrict');

            $table->string('codigo_producto', 50)->unique();
            $table->string('nombre_producto', 100);
            $table->string('marca', 50);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('productos');
    }
};


