<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class BarangSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('barang')->insert([
            [
                'nama_barang' => 'TRANYO 120W gaN fast charger',
                'deskripsi' => 'TRANYO 120W GaN Fast Charger adalah pengisi daya cepat yang menggunakan teknologi GaN untuk memberikan pengisian daya yang lebih efisien dan cepat. Dengan daya output hingga 120 watt, charger ini mampu mengisi daya berbagai perangkat elektronik seperti laptop, smartphone, dan tablet dengan kecepatan tinggi. Desainnya yang kompak dan portabel membuatnya mudah dibawa ke mana saja.',
                'harga' => 150000,
                'stok' => 20,              
            ],
            [
                'nama_barang' => 'Mouse Gaming Nirkabel MOFii',
                'deskripsi' => 'Mouse Gaming Nirkabel MOFii adalah mouse gaming yang dirancang untuk memberikan pengalaman bermain game yang optimal. Dengan koneksi nirkabel, mouse ini menawarkan kebebasan bergerak tanpa kabel yang mengganggu. Dilengkapi dengan sensor presisi tinggi dan tombol yang responsif, mouse ini cocok untuk para gamer yang menginginkan performa tinggi dan kenyamanan saat bermain.',
                'harga' => 125000,
                'stok' => 15,
            ],
            [
                'nama_barang' => 'Earphone KY X66 transparent',
                'deskripsi' => 'Earphone KY X66 Transparent adalah earphone berkualitas tinggi dengan desain transparan yang stylish. Earphone ini menawarkan kualitas suara yang jernih dan bass yang kuat, cocok untuk mendengarkan musik, menonton film, atau bermain game. Dengan desain ergonomis yang nyaman, earphone ini dapat digunakan dalam waktu lama tanpa menyebabkan ketidaknyamanan pada telinga.',
                'harga' => 85000,
                'stok' => 30,
            ],
        ]);
    }
}
