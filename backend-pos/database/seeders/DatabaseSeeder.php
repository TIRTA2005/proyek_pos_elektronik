<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Admin
        \App\Models\User::factory()->create([
            'name' => 'Admin Utama',
            'email' => 'admin@pos.com',
            'password' => bcrypt('password'),
            'role' => 'admin',
        ]);

        // Kasir
        \App\Models\User::factory()->create([
            'name' => 'Kasir Satu',
            'email' => 'kasir@pos.com',
            'password' => bcrypt('password'),
            'role' => 'kasir',
        ]);

        // Barang
        $barangs = [
            ['nama_barang' => 'Charger GaN 120W', 'deskripsi' => 'Charger super cepat', 'harga' => 250000, 'stok' => 50],
            ['nama_barang' => 'Kabel Data Type-C', 'deskripsi' => 'Kabel braided 2m', 'harga' => 50000, 'stok' => 100],
            ['nama_barang' => 'Mouse Wireless Gaming', 'deskripsi' => 'Mouse RGB silent', 'harga' => 150000, 'stok' => 20],
        ];

        foreach ($barangs as $b) {
            \App\Models\Barang::create($b);
        }
    }
}
