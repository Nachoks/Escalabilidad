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
        Schema::create('gasto_archivo', function (Blueprint $table) {
            $table->id('id_gasto_archivo');
            $table->unsignedBigInteger('id_gasto');

            $table->string('nombre_original', 255);
            $table->string('nombre_fisico', 255);
            $table->string('ruta_relativa', 255);
            $table->string('extension', 255)->nullable();

            // En diagrama figura como Integer(10,2) Default 0 -> lo represento como decimal
            $table->decimal('peso_kb', 10, 2)->default(0);

            $table->timestamp('created_at')->useCurrent();

            $table->unsignedBigInteger('id_validador')->nullable();

            $table->foreign('id_gasto')
                ->references('id_gasto')->on('gasto')
                ->onUpdate('cascade')
                ->onDelete('cascade');

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
        Schema::dropIfExists('gasto_archivo');
    }
};
