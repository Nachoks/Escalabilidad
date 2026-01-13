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
        Schema::create('has_guia', function (Blueprint $table) {
            $table->id('id_has_guia');
            $table->string('cod_has_guia', 255);
            $table->unsignedBigInteger('id_servicio');

            $table->foreign('id_servicio')
                ->references('id_servicio')->on('servicio')
                ->onUpdate('cascade')
                ->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('has_guia');
    }
};
