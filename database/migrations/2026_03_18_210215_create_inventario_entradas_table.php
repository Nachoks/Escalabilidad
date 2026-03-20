<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('inventario_entradas', function (Blueprint $table) {
            $table->id('id_entrada');
            
            $table->foreignId('id_producto')
                  ->constrained('productos', 'id_producto');
            
            // Relacionado con tu tabla "usuarios" actual
            $table->foreignId('id_responsable')
                  ->constrained('usuarios', 'id_usuario');

            $table->string('oc_proveedor', 50)->nullable();
            $table->string('serial', 50)->unique();
            $table->enum('estado_serial', ['Disponible', 'Entregado', 'Defectuoso'])->default('Disponible');
            
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('inventario_entradas');
    }
};


