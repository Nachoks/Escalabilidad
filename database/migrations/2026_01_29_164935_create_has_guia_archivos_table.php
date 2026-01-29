<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('has_guia_archivos', function (Blueprint $table) {
            $table->id('id_archivo');
            
            // Relación con la HAS
            $table->unsignedBigInteger('id_has_guia');

            // Datos del archivo
            $table->string('nombre_original', 255); // Nombre real (ej: foto.jpg)
            $table->string('nombre_fisico', 255);   // Nombre único (ej: 123_foto.jpg)
            $table->string('ruta_relativa', 255);   // Carpeta (ej: guias/2026/)
            $table->string('extension', 10);        // ej: jpg
            $table->integer('peso_kb');             // Peso en KB

            // Foreign Key
            $table->foreign('id_has_guia')
                ->references('id_has_guia')->on('has_guia')
                ->onUpdate('cascade')
                ->onDelete('cascade'); // Si borran la guía, se borran sus fotos
            
            // Sin timestamps
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('has_guia_archivos');
    }
};