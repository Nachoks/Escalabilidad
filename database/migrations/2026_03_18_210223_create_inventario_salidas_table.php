<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('inventario_salidas', function (Blueprint $table) {
            $table->id('id_salida');

            $table->foreignId('id_entrada')
                  ->constrained('inventario_entradas', 'id_entrada');

            $table->foreignId('id_producto')
                  ->constrained('productos', 'id_producto');

            // Relacionado con tu tabla "cliente" actual
            $table->foreignId('id_cliente')
                  ->constrained('cliente', 'id_cliente');

            // Relacionado con tu tabla "usuarios" actual
            $table->foreignId('id_responsable')
                  ->constrained('usuarios', 'id_usuario');

            $table->string('oc_cliente', 50)->nullable();
            $table->string('serial', 50);

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('inventario_salidas');
    }
};

