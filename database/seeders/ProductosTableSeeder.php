<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class ProductosTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('productos')->delete();
        
        \DB::table('productos')->insert(array (
            0 => 
            array (
                'id_producto' => 1,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE013234R1',
                'nombre_producto' => 'A845 - TU830V1 Extended MTU. 50V',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            1 => 
            array (
                'id_producto' => 2,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSC610066R1',
                'nombre_producto' => 'A150 - SD833 Power Supply. 10A',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            2 => 
            array (
                'id_producto' => 3,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSC610068R1',
                'nombre_producto' => 'A190 - SS832 Power Voting Unit',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            3 => 
            array (
                'id_producto' => 4,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE008512R1',
                'nombre_producto' => 'A480 - DI820 Digital Input 120V a.c. 8 ch',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            4 => 
            array (
                'id_producto' => 5,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE041882R1',
                'nombre_producto' => 'A070 - CI840A PROFIBUS DP-V1 Interface',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            5 => 
            array (
                'id_producto' => 6,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE022462R1',
                'nombre_producto' => 'A090 - TU847 MTU for CI840',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            6 => 
            array (
                'id_producto' => 7,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE008516R1',
                'nombre_producto' => 'A310 - AI810 Analog Input 8 ch',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            7 => 
            array (
                'id_producto' => 8,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE081637R1',
                'nombre_producto' => 'P144 - PM866AK02 Redundant Processor Unit',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            8 => 
            array (
                'id_producto' => 9,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE013235R1',
                'nombre_producto' => 'A850 - TU831V1 Extended MTU. 250V',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            9 => 
            array (
                'id_producto' => 10,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE091722R1',
                'nombre_producto' => 'B220 - LD 810HSE EX Linking Device',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            10 => 
            array (
                'id_producto' => 11,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE069449R1',
                'nombre_producto' => 'P277 - CI854BK01 PROFIBUS-DP/V1 interface',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            11 => 
            array (
                'id_producto' => 12,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE031155R1',
                'nombre_producto' => 'P460 - BC810K02 CEX-bus Interconnection Unit',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            12 => 
            array (
                'id_producto' => 13,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE018172R1',
                'nombre_producto' => 'P175 - SB822 Rechargeable Battery Unit',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            13 => 
            array (
                'id_producto' => 14,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE040662R1',
                'nombre_producto' => 'A330 - AI830A Analog input RTD 8 ch',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            14 => 
            array (
                'id_producto' => 15,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE008514R1',
                'nombre_producto' => 'A580 - DO820 Digital Output Relay 8 ch',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            15 => 
            array (
                'id_producto' => 16,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE032444R1',
                'nombre_producto' => 'P295 - CI860K01 FF HSE Interface',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            16 => 
            array (
                'id_producto' => 17,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE076939R1',
                'nombre_producto' => 'P143 - PM866AK01 Processor Unit',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            17 => 
            array (
                'id_producto' => 18,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSC610067R1',
                'nombre_producto' => 'A160 - SD834 Power Supply. 20A',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            18 => 
            array (
                'id_producto' => 19,
                'id_proveedor' => 5,
                'codigo_producto' => '2PAA125624R1',
                'nombre_producto' => 'A195 - SS855 Power Voting Unit 40A',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            19 => 
            array (
                'id_producto' => 20,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE092978R1',
                'nombre_producto' => 'B140 - PP881 Standard Panel 10',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            20 => 
            array (
                'id_producto' => 21,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE092693R1',
                'nombre_producto' => 'P285 - CI871AK01 Profinet IO Interface',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            21 => 
            array (
                'id_producto' => 22,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE013230R1',
                'nombre_producto' => 'A810 - TU810V1 Compact MTU. 50V',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            22 => 
            array (
                'id_producto' => 23,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE052605R1',
                'nombre_producto' => 'A415 - AO815 Analog Output HART 8 ch',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            23 => 
            array (
                'id_producto' => 24,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE052604R1',
                'nombre_producto' => 'A315 - AI815 Analog Input HART 8 ch',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            24 => 
            array (
                'id_producto' => 25,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE076220R1',
                'nombre_producto' => 'A094 - TC810 Ethernet Adapter for Ethernet FCI',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            25 => 
            array (
                'id_producto' => 26,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE078710R1',
                'nombre_producto' => 'A092 - TU860 MTU for Ethernet FCI and S800',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            26 => 
            array (
                'id_producto' => 27,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE075853R1',
                'nombre_producto' => 'A080 - CI845 Ethernet FCI module',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            27 => 
            array (
                'id_producto' => 28,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE022366R1',
                'nombre_producto' => 'A050 - CI801 PROFIBUS FCI S800 Interface',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            28 => 
            array (
                'id_producto' => 29,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE008508R1',
                'nombre_producto' => 'A460 - DI810 Digital Input 24V 16 ch',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            29 => 
            array (
                'id_producto' => 30,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE092689R1',
                'nombre_producto' => 'P265 - CI867AK01 Modbus TCP',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            30 => 
            array (
                'id_producto' => 31,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE069055R1',
                'nombre_producto' => 'A590 - DO828 Digital Output. Relay 16 ch',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            31 => 
            array (
                'id_producto' => 32,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE069054R1',
                'nombre_producto' => 'A495 - DI828 Digital Input 120V 16 ch',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            32 => 
            array (
                'id_producto' => 33,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE068782R1',
                'nombre_producto' => 'A915 - TU851 Extended MTU. 250V',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            33 => 
            array (
                'id_producto' => 34,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSC610065R1',
                'nombre_producto' => 'A140 - SD832 Power Supply, 5A ',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            34 => 
            array (
                'id_producto' => 35,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE080207R1',
                'nombre_producto' => 'A020 - NE810 Network switch',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            35 => 
            array (
                'id_producto' => 36,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE008538R1',
                'nombre_producto' => 'B185 - TB807 Modulebus terminator ',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            36 => 
            array (
                'id_producto' => 37,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE013208R1',
                'nombre_producto' => 'B190 - TB820V2 Modulebus Cluster Modem',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            37 => 
            array (
                'id_producto' => 38,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE078714R1',
                'nombre_producto' => 'A095 - TC811 Ethernet Adapter Single Mode Fiber',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            38 => 
            array (
                'id_producto' => 39,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE008536R1',
                'nombre_producto' => 'B160 - TB806 Bus Inlet',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            39 => 
            array (
                'id_producto' => 40,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE022464R1',
                'nombre_producto' => 'B220-TB842 Modulebus Optical Port',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            40 => 
            array (
                'id_producto' => 41,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSC950107R1',
                'nombre_producto' => 'B250 - TK811V015 POF Cable. 1.5m. Duplex',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            41 => 
            array (
                'id_producto' => 42,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE090784R1',
                'nombre_producto' => 'P335 - CI874K01 OPC UA Client Interface',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
            42 => 
            array (
                'id_producto' => 43,
                'id_proveedor' => 5,
                'codigo_producto' => '3BSE013210R1',
                'nombre_producto' => 'A500 - DI830 Digital Input 24V SOE 16 ch',
                'marca' => 'Desconocida',
                'created_at' => '2026-04-16 04:06:32',
                'updated_at' => '2026-04-16 04:06:32',
            ),
        ));
        
        
    }
}