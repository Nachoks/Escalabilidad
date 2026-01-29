<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('has_guia', function (Blueprint $table) {
            $table->id('id_has_guia');
            
            // CAMBIO: Ahora se relaciona con la OC, no con el servicio directo
            $table->unsignedBigInteger('id_oc_cliente'); 
            
            // Datos
            $table->string('cod_has_guia', 255);

            // Foreign Key
            $table->foreign('id_oc_cliente')
                ->references('id_oc_cliente')->on('oc_cliente')
                ->onUpdate('cascade')
                ->onDelete('cascade'); // Si borran la OC, se borran sus guías
            
            // Sin timestamps
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('has_guia');
    }
};