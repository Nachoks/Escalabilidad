<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('contactos_proveedores', function (Blueprint $table) {
            $table->id('id_contacto');
            $table->unsignedBigInteger('id_proveedor'); // Llave foránea
            $table->string('nombre_contacto', 100);
            $table->string('cargo', 100)->nullable();
            $table->string('numero_contacto', 50)->nullable();
            $table->string('correo_contacto', 100)->nullable();
            $table->timestamps();

            // Relación en cascada: Si borras el proveedor, se borran sus contactos
            $table->foreign('id_proveedor')
                  ->references('id_proveedor')->on('proveedores')
                  ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('contactos_proveedores');
    }
};
