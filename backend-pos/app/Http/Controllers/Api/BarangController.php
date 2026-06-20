<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;

class BarangController extends Controller
{
    public function index()
    {
    
        $barang = DB::table('barang')->get();
        

        return response()->json([
            'status' => 'success',
            'data' => $barang
        ]);
    }
}