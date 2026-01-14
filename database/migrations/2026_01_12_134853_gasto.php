<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('gasto', function (Blueprint $table) {
            $table->id('id_gasto');
            $table->date('fecha')->nullable();
            $table->string('num_documento', 255)->nullable();
            $table->integer('monto')->nullable();
            
            $table->string('estado_gasto', 255)->default('Pendiente');
            $table->string('comentario_validador', 255)->nullable();

            // --- CAMPOS DE TEXTO (REEMPLAZAN LAS TABLAS MAESTRAS) ---
            $table->string('tipo_documento', 255)->nullable(); // Ej: "Boleta"
            $table->string('detalle', 255)->nullable();        // Ej: "Alimentación"

            // --- RELACIONES (SOLO PADRE Y VALIDADOR) ---
            $table->unsignedBigInteger('id_rendicion');
            $table->unsignedBigInteger('id_validador')->nullable();

            $table->foreign('id_rendicion')
                ->references('id_rendicion')->on('rendicion')
                ->onUpdate('cascade')
                ->onDelete('cascade');

            $table->foreign('id_validador')
                ->references('id_usuario')->on('usuarios')
                ->onUpdate('cascade')
                ->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('gasto');
    }
};