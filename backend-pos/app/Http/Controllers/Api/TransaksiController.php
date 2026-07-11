<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class TransaksiController extends Controller
{
    public function store(Request $request)
    {
        $cart = $request->input('cart');
        $total_harga = $request->input('total_harga');

        DB::beginTransaction();
        try {
            $transaksi_id = DB::table('transaksi')->insertGetId([
                'user_id' => $request->user()->id, 
                'pelanggan_id' => null, 
                'total_harga' => $total_harga,
                'tanggal_transaksi' => Carbon::now(),
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ]);

            foreach ($cart as $item) {
                DB::table('detail_transaksi')->insert([
                    'transaksi_id' => $transaksi_id,
                    'barang_id' => $item['id'],
                    'kuantitas' => $item['kuantitas'],
                    'harga_satuan' => $item['harga'],
                    'subtotal' => $item['subtotal'],
                    'created_at' => Carbon::now(),
                    'updated_at' => Carbon::now(),
                ]);

                DB::table('barang')
                    ->where('id', $item['id'])
                    ->decrement('stok', $item['kuantitas']);
            }

            DB::commit();
            return response()->json(['status' => 'success', 'message' => 'Transaksi berhasil diproses!']);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['status' => 'error', 'message' => 'Gagal memproses transaksi: ' . $e->getMessage()]);
        }
    }
}