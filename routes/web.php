<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/version', function () {
    $archivo = base_path('VERSION');

    return response()->json([
        'aplicacion' => config('app.name'),
        'version' => file_exists($archivo) ? trim(file_get_contents($archivo)) : 'desarrollo',
        'alumno' => 'Marcos Jesús Ugalde Zarza',
        'matricula' => '222310597',
        'grupo' => 'IDGS-102',
        'entorno' => app()->environment(),
    ], 200, [], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
});
