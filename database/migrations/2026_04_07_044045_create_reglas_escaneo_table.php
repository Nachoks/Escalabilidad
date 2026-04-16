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
        Schema::create('reglas_escaneo', function (Blueprint $table) {
            // Usamos id_regla para mantener la convención que usas en otras tablas (ej: id_cliente)
            $table->id('id_regla'); 
            $table->string('nombre_marca', 100);
            
            // Los prefijos pueden contener caracteres especiales como ]C1
            $table->string('prefijo_codigo', 50)->nullable(); 
            $table->string('prefijo_serie', 50)->nullable();
            
            // El número o símbolo que divide el código de la serie y que la cámara debe ignorar
            $table->string('separador_ignorar', 50)->nullable();
            
            $table->timestamps();
        });
    }


    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reglas_escaneo');
    }
};


