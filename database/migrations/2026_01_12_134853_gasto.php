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
          Schema::create('gasto', function (Blueprint $table) {
            $table->id('id_gasto');
            $table->date('fecha')->nullable();
            $table->string('num_documento', 255)->nullable();
            $table->integer('monto')->nullable();

            $table->string('estado_gasto', 255)->nullable();
            $table->string('comentario_validador', 255)->nullable();

            $table->unsignedBigInteger('id_validador')->nullable(); // usuario
            $table->string('categoria_otro', 255)->nullable();

            $table->unsignedBigInteger('id_rendicion');
            $table->unsignedBigInteger('id_tipo_documento');
            $table->unsignedBigInteger('id_categoria_gasto');

            $table->foreign('id_rendicion')
                ->references('id_rendicion')->on('rendicion')
                ->onUpdate('cascade')
                ->onDelete('cascade');

            $table->foreign('id_tipo_documento')
                ->references('id_tipo_documento')->on('tipo_documento')
                ->onUpdate('cascade')
                ->onDelete('restrict');

            $table->foreign('id_categoria_gasto')
                ->references('id_categoria_gasto')->on('categoria_gasto')
                ->onUpdate('cascade')
                ->onDelete('restrict');

            $table->foreign('id_validador')
                ->references('id_usuario')->on('usuarios')
                ->onUpdate('cascade')
                ->onDelete('set null');
        });

    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('gasto');
    }
};
