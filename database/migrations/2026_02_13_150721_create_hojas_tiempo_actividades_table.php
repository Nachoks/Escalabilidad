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
        // Corregido el nombre a plural correcto en español: hojas_tiempo_actividades
        Schema::create('hojas_tiempo_actividades', function (Blueprint $table) {
            // 1. Llave primaria personalizada
            $table->id('id_actividad');
            
            // 2. Relación con el Día (Padre)
            $table->unsignedBigInteger('id_hoja_diaria');
            $table->foreign('id_hoja_diaria')
                  ->references('id_hoja_diaria')
                  ->on('hojas_tiempo_diarias')
                  ->onDelete('cascade'); // Si se borra el día, se borran sus actividades
            
            // 3. RELOJ Y DETALLE
            $table->time('hora_inicio');
            $table->time('hora_fin');
            $table->text('descripcion');
            
            // 4. CÁLCULOS AUTOMÁTICOS (El backend llenará esto después)
            $table->float('horas_habiles')->default(0);
            $table->float('horas_no_habiles')->default(0);
            $table->float('horas_festivas')->default(0);
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Corregido también aquí para el rollback
        Schema::dropIfExists('hojas_tiempo_actividades');
    }
};