# Personalización de paquetes npm

A diferencia de las gemas Ruby que tienen un archivo `Gemfile_custom` separado, las dependencias npm se añaden directamente al archivo `package.json`. Este documento lista las personalizaciones realizadas para facilitar futuras actualizaciones.

## Dependencias de desarrollo custom

Las siguientes `devDependencies` han sido añadidas para la personalización de GVA:

```json
"@commitlint/cli": "^19.0.0",
"@commitlint/config-conventional": "^19.0.0"
```

Estas dependencias permiten validar que los mensajes de commit sigan el formato [Conventional Commits](https://www.conventionalcommits.org/).

## Scripts npm custom

Los siguientes scripts han sido añadidos a la sección `scripts` del `package.json` para centralizar comandos que se utilizan tanto en hooks de git (lefthook) como en pipelines de CI:

```json
"test:rspec": "bundle exec rspec",
"test:rspec-failures": "bundle exec rspec --only-failures --next-failure",
"lint:rubocop": "bundle exec rubocop",
"lint:eslint": "eslint",
"commitlint": "commitlint"
```

Estos scripts se pueden ejecutar con:

```bash
npm run audit:gems
npm run test:rspec
npm run lint:rubocop
# etc.
```

## Configuración de ESLint

En el archivo `.eslintrc.json` se ha añadido la siguiente configuración en la sección `overrides` para permitir que archivos de configuración Node.js (`*.config.js`) sean validados correctamente:

```json
"overrides": [
  {
    "files": ["*.config.js"],
    "env": {
      "node": true,
      "commonjs": true
    },
    "parserOptions": {
      "ecmaVersion": 2020
    }
  }
]
```

Esto permite que archivos como `commitlint.config.js` utilicen sintaxis de Node.js (`module.exports`, `require()`) sin generar errores de linting.

## Añadir nuevas dependencias

Para añadir nuevos paquetes npm, edita directamente el archivo `package.json` y ejecuta:

```bash
npm install
```

**Importante**: Al actualizar Consul Democracy, revisa este documento y verifica que las dependencias custom no generen conflictos con las nuevas versiones.
