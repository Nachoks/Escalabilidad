<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class GastoTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('gasto')->delete();
        
        
        
    }
}