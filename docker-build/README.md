# docker-build — Compilación para RHEL 9

Entorno Docker para compilar las gemas nativas y precompilar los assets JS/CSS
en un contenedor RHEL 9 (UBI), equivalente al servidor de producción de la GVA.

## Por qué existe esto

Los binarios de gemas con extensiones nativas (como `pg`) son específicos de la
plataforma. Si se compilan en Ubuntu/macOS y se despliegan en RHEL 9, fallan.
Este contenedor garantiza que `vendor/bundle` y `public/assets` se generan con
el mismo SO y arquitectura que producción.

## Estructura esperada

El repo SVN de la aplicación debe estar en el directorio **hermano** de este repo git:

```
/home/.../
├── consul_gva/          ← este repo git (donde está docker-build/)
│   └── docker-build/
│       ├── Dockerfile
│       ├── docker-compose.yml
│       └── entrypoint.sh
└── consul_gva_svn/      ← working copy SVN (fuentes/ + node_modules/ + vendor/)
```

El SVN working copy apunta a: `https://subversion.gva.es/svn/participem_gv` → `trunk/fuentes`

## Uso

Desde la raíz del proyecto Rails (`consul_gva/`), usando las tareas rake
(`lib/tasks/custom/docker_build.rake`):

```bash
# Construir la imagen (solo la primera vez o al cambiar Dockerfile)
bin/rake docker_build:build

# Ejecutar la compilación completa
bin/rake docker_build:compile

# Build + compile en un solo paso
bin/rake docker_build:run

# Eliminar la imagen Docker de compilación
bin/rake docker_build:clean

# Si tu working copy SVN tiene un nombre o ruta diferente, pásalo con SVN_PATH:
SVN_PATH=/ruta/a/tu/svn bin/rake docker_build:compile
```

Por defecto apunta a `../../consul_gva_svn`. Puedes definir `SVN_PATH` en un
fichero `.env` en esta misma carpeta para no tener que pasarlo cada vez:

```bash
# docker-build/.env
SVN_PATH=/home/usuario/otro_nombre_svn
```

El contenedor monta el directorio padre (`consul_gva_svn/`) como `/app` y ejecuta:

1. `bundle install` — compila gemas nativas para RHEL 9 en `vendor/bundle`
2. `rake assets:precompile` — genera `public/assets`
3. Deja `vendor/bundle` y `public/assets` listos en el working copy SVN. Subida
   manual: `bin/actualiza_svn.sh` (añade ficheros nuevos/binarios `.so` y elimina
   los borrados) seguido de `svn commit`

## Versiones

| Componente | Versión |
|------------|---------|
| Ruby       | 3.3.10  |
| Node       | 20.x    |
| SO base    | AlmaLinux 9 (compatible RHEL 9) |

## Variables de entorno requeridas

| Variable   | Descripción                        |
|------------|------------------------------------|
| `SVN_USER` | Usuario de Subversion de la GVA    |
| `SVN_PASS` | Contraseña de Subversion de la GVA |

## Notas

- Si el equipo de compilación usa **Mac con Apple Silicon (ARM)**, descomentar
  `platform: linux/amd64` en `docker-compose.yml` para generar binarios x86_64
  compatibles con el servidor RHEL.
- `node_modules/` en el SVN es intencionado: los assets precompilados requieren
  las dependencias JS presentes para el despliegue.
