<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('areas_empresa', function (Blueprint $table) {
            // 1. PK con nombre explícito para evitar confusiones
            $table->id('id_area'); 
            
            // 2. Relación con tu tabla 'empresa'
            $table->unsignedBigInteger('id_empresa');
            $table->foreign('id_empresa')
                  ->references('id_empresa')->on('empresa')
                  ->onDelete('cascade');

            // 3. Datos del Área
            $table->string('nombre_area');  // Ej: "Ciberseguridad"
            $table->integer('codigo_area'); // Ej: 1, 2... (Dato clave para el Centro de Costo)

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('areas_empresa');
    }
};
