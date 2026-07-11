<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Barang;

class BarangController extends Controller
{
    public function index()
    {
        $barang = Barang::all();
        return response()->json(['status' => 'success', 'data' => $barang]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama_barang' => 'required|string',
            'deskripsi' => 'nullable|string',
            'harga' => 'required|integer',
            'stok' => 'required|integer',
        ]);

        $barang = Barang::create($validated);
        return response()->json(['status' => 'success', 'data' => $barang]);
    }

    public function show($id)
    {
        $barang = Barang::find($id);
        if (!$barang) return response()->json(['status' => 'error', 'message' => 'Barang tidak ditemukan'], 404);
        return response()->json(['status' => 'success', 'data' => $barang]);
    }

    public function update(Request $request, $id)
    {
        $barang = Barang::find($id);
        if (!$barang) return response()->json(['status' => 'error', 'message' => 'Barang tidak ditemukan'], 404);

        $validated = $request->validate([
            'nama_barang' => 'sometimes|string',
            'deskripsi' => 'nullable|string',
            'harga' => 'sometimes|integer',
            'stok' => 'sometimes|integer',
        ]);

        $barang->update($validated);
        return response()->json(['status' => 'success', 'data' => $barang]);
    }

    public function destroy($id)
    {
        $barang = Barang::find($id);
        if (!$barang) return response()->json(['status' => 'error', 'message' => 'Barang tidak ditemukan'], 404);

        $barang->delete();
        return response()->json(['status' => 'success', 'message' => 'Barang dihapus']);
    }
}