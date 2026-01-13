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
        Schema::create('servicio', function (Blueprint $table) {
            $table->id('id_servicio');
            $table->string('nombre_servicio', 255);
            $table->unsignedBigInteger('id_cliente'); // FK cliente
            $table->unsignedBigInteger('id_area');
            $table->string('centro_costo', 10)->nullable();
            $table->date('fecha_inicio')->nullable();
            $table->date('fecha_termino')->nullable();
            $table->string('estado_servicio', 255)->nullable();
            $table->string('facturacion', 255)->nullable();
            $table->integer('correlativo')->nullable();

            $table->foreign('id_cliente')
                ->references('id_cliente')->on('cliente')
                ->onUpdate('cascade')
                ->onDelete('restrict');
            $table->foreign('id_area')
                ->references('id_area')->on('areas_empresa') // Apunta a tu tabla nueva
                ->onUpdate('cascade')
                ->onDelete('restrict');
        });
    }

    /**
     * Reverse the migrations.
     */
    
    public function down(): void
    {
        Schema::dropIfExists('servicio');
    }
    
    
};
