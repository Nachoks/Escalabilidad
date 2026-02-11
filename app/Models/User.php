<?php

namespace App\Models;

// Importante: Agrega esto para que funcione la API (tokens)
use Laravel\Sanctum\HasApiTokens; 
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    //Definir tabla personalizada
    protected $table = 'usuarios';

    //Definir llave primaria personalizada
    protected $primaryKey = 'id_usuario';

    /**
     * Los atributos que se pueden asignar masivamente.
     */
    protected $fillable = [
        'nombre_usuario', 
        'password',       
        'id_personal',
        'estado',
        'onesignal_id',
    ];

    /**
     * Atributos que no se deben mostrar en la respuesta JSON.
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Configuraciones de tipos de datos.
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'estado' => 'boolean', 
        ];
    }

    // -----------------------------------------------------------------------
    // [NUEVO] 1. Agregamos estos atributos virtuales al JSON siempre
    // -----------------------------------------------------------------------
    protected $appends = ['nombre', 'apellido'];

    public function personal()
    {
        return $this->belongsTo(Personal::class, 'id_personal', 'id_personal');
    }

    /*
     * Relación: Un Usuario tiene muchos Roles (Tipos).
     */
    public function roles()
    {
        return $this->belongsToMany(
            TipoUsuario::class, 
            'usuario_rol',      
            'id_usuario',       
            'id_tipo_usuario'   
        );
    }

    // -----------------------------------------------------------------------
    // [NUEVO] 2. Métodos mágicos para obtener nombre y apellido desde Personal
    // -----------------------------------------------------------------------
    
    // Esto crea el atributo virtual 'nombre'
    public function getNombreAttribute()
    {
        // Si existe la relación 'personal', devuelve 'nombre_personal', si no, null
        return $this->personal ? $this->personal->nombre_personal : null;
    }

    // Esto crea el atributo virtual 'apellido'
    public function getApellidoAttribute()
    {
        // Si existe la relación 'personal', devuelve 'apellido_personal', si no, null
        return $this->personal ? $this->personal->apellido_personal : null;
    }
}