<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('hojas_tiempo_semanas', function (Blueprint $table) {
            // 1. Mantenemos tu estándar de llaves primarias
            $table->id('id_hoja_semana'); 
            
            // 2. Definir las columnas para las llaves foráneas
            $table->unsignedBigInteger('id_usuario');
            $table->unsignedBigInteger('id_servicio');
            $table->unsignedBigInteger('id_oc_cliente');
            
            // 3. Relaciones EXACTAS apuntando a tus tablas reales
            $table->foreign('id_usuario')->references('id_usuario')->on('usuarios')->onDelete('cascade');
            $table->foreign('id_servicio')->references('id_servicio')->on('servicio')->onDelete('cascade');
            $table->foreign('id_oc_cliente')->references('id_oc_cliente')->on('oc_cliente')->onDelete('cascade');
            
            // DATOS CONGELADOS
            $table->string('centro_costo', 50)->nullable();
            $table->integer('numero_semana');
            
            // PERIODO Y ESTADO
            $table->date('fecha_inicio'); // Lunes
            $table->date('fecha_fin');    // Domingo
            $table->enum('estado', ['Borrador', 'Enviada', 'Aprobada', 'Rechazada'])->default('Borrador');
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Corregido: Faltaba la "s" inicial
        Schema::dropIfExists('hojas_tiempo_semanas');
    }
};