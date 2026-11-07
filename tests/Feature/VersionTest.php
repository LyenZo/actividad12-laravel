<?php

namespace Tests\Feature;

use Tests\TestCase;

class VersionTest extends TestCase
{
    public function test_la_ruta_version_devuelve_los_datos_del_alumno(): void
    {
        $respuesta = $this->get('/version');

        $respuesta->assertOk()
            ->assertJsonPath('alumno', 'Marcos Jesús Ugalde Zarza')
            ->assertJsonPath('matricula', '222310597')
            ->assertJsonStructure(['aplicacion', 'version', 'alumno', 'matricula', 'grupo', 'entorno']);
    }
}
