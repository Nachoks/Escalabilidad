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
            // 1. Llave primaria
            $table->id('id_hoja_semana'); 
            
            // 2. Llaves foráneas
            $table->unsignedBigInteger('id_usuario');
            $table->unsignedBigInteger('id_servicio');
            $table->unsignedBigInteger('id_oc_cliente');
            
            // 3. Relaciones
            $table->foreign('id_usuario')->references('id_usuario')->on('usuarios')->onDelete('cascade');
            $table->foreign('id_servicio')->references('id_servicio')->on('servicio')->onDelete('cascade');
            $table->foreign('id_oc_cliente')->references('id_oc_cliente')->on('oc_cliente')->onDelete('cascade');
            
            // --- NUEVOS CAMPOS PARA IDENTIFICACIÓN ---
            // El número que ingresa el usuario (1-99)
            $table->integer('numero_hct'); 
            // El nombre final: correlativo-HTC-numero_hct (ej: 01-01-12-HTC-23)
            $table->string('nombre_comprobante')->nullable(); 
            
            // DATOS CONGELADOS
            $table->string('centro_costo', 50)->nullable();
            $table->integer('numero_semana');
            
            // PERIODO Y ESTADO
            $table->date('fecha_inicio'); // Lunes
            $table->date('fecha_fin');    // Domingo
            $table->enum('estado', ['Borrador', 'Enviada', 'Aprobada', 'Rechazada'])->default('Borrador');
            
            $table->timestamps();

            // 4. REGLA DE UNICIDAD: Impide que un mismo servicio tenga dos veces la misma HCT
            $table->unique(['id_servicio', 'numero_hct'], 'uidx_servicio_hct');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('hojas_tiempo_semanas');
    }
};