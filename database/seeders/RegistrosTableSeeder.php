<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class RegistrosTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('registros')->delete();
        
        
        
    }
}