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
        Schema::create('registros', function (Blueprint $table) {
            $table->id('id_registro_rendicion');
            $table->unsignedBigInteger('id_rendicion');
            
            $table->unsignedBigInteger('id_usuario_pagador')->nullable();
            
            $table->date('fecha_pago')->nullable();
            $table->integer('monto_pagado')->nullable();

            $table->string('nombre_original', 255)->nullable();
            $table->string('nombre_fisico', 255)->nullable();

            $table->string('ruta_relativa', 255)->nullable();
            $table->decimal('peso_kb', 10, 2)->default(0);
            $table->string('extension', 255)->nullable();
            $table->timestamps();
            $table->foreign('id_rendicion')
                ->references('id_rendicion')->on('rendicion')
                ->onUpdate('cascade')
                ->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('registros');
    }
};
