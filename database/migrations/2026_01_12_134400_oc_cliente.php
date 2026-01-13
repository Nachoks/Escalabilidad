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
        Schema::create('oc_cliente', function (Blueprint $table) {
            $table->id('id_oc_cliente');
            $table->string('cod_oc_cliente', 255);
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
        Schema::dropIfExists('oc_cliente');
    }
};
