<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;


return new class extends Migration
{
    public function up(): void
    {
        Schema::create('inventario_productos', function (Blueprint $table) {
            $table->id('id_inventario');
            
            // Relación 1 a 1 con productos (Unique garantiza que no se repitan)
            $table->foreignId('id_producto')
                  ->unique()
                  ->constrained('productos', 'id_producto')
                  ->onDelete('cascade');

            $table->integer('stock_actual')->default(0);
            $table->integer('stock_minimo')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('inventario_productos');
    }
};

