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
        Schema::create('rendicion', function (Blueprint $table) {
            $table->id('id_rendicion');
            $table->date('fecha')->nullable();
            $table->string('proposito', 255)->nullable();
            $table->integer('monto_entregado')->nullable();
            $table->string('estado', 255)->nullable();
            $table->string('centro_costo', 255)->nullable();

            $table->unsignedBigInteger('id_servicio');
            $table->unsignedBigInteger('id_usuario');

            $table->foreign('id_servicio')
                ->references('id_servicio')->on('servicio')
                ->onUpdate('cascade')
                ->onDelete('restrict');

            $table->foreign('id_usuario')
                ->references('id_usuario')->on('usuarios')
                ->onUpdate('cascade')
                ->onDelete('restrict');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('rendicion');
    }
};
