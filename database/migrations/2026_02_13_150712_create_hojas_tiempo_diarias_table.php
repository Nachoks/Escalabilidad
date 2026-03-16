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
        Schema::create('hojas_tiempo_diarias', function (Blueprint $table) {
            // 1. Llave primaria personalizada
            $table->id('id_hoja_diaria');
           
            // 2. Relación con la Semana (Padre)
            $table->unsignedBigInteger('id_hoja_semana');
            $table->foreign('id_hoja_semana')
                  ->references('id_hoja_semana')
                  ->on('hojas_tiempo_semanas')
                  ->onDelete('cascade'); // Si borras la semana, se borran sus 7 días
           
            // 3. Fecha específica del día
            $table->date('fecha');
           
            // 4. CONFIGURACIÓN DEL DÍA
            $table->enum('lugar', ['OFICINA', 'TERRENO', 'DESCANSO'])->default('DESCANSO');
            $table->string('area')->nullable();
            $table->enum('tipo_dia', ['HABIL', 'NO_HABIL', 'FERIADO'])->default('NO_HABIL');
           
            // 5. Límite de horas (Solo aplica si el tipo_dia es HÁBIL)
            $table->time('horario_inicio')->nullable();
            $table->time('horario_fin')->nullable();
           
            // 6. VIAJES INTEGRADOS
            $table->float('viaje_horas')->default(0);


            // 7. ESTADO Y OBSERVACIÓN
            $table->enum('estado', ['Borrador', 'Enviada', 'Aprobada', 'Rechazada'])->default('Borrador');
            $table->text('observacion')->nullable();
           
            // --- 8. NUEVO: VALIDADOR ---
            $table->unsignedBigInteger('validador_id')->nullable();
            $table->foreign('validador_id')->references('id_usuario')->on('usuarios')->onDelete('set null');
           
            $table->timestamps();
        });
    }


    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('hojas_tiempo_diarias');
    }
};


