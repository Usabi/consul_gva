namespace :docker_build do
  DOCKER_BUILD_DIR = Rails.root.join("docker-build").to_s

  desc "Construye la imagen Docker para compilación en AlmaLinux 9 (compatible RHEL 9)"
  task :build do
    system("docker compose build", chdir: DOCKER_BUILD_DIR) ||
      abort("Error al construir la imagen Docker")
  end

  desc "Compila gemas nativas y assets dentro del contenedor AlmaLinux 9. Acepta SVN_PATH=ruta"
  task :compile do
    env = ENV["SVN_PATH"] ? { "SVN_PATH" => ENV["SVN_PATH"] } : {}
    system(env, "docker compose run --rm build", chdir: DOCKER_BUILD_DIR) ||
      abort("Error durante la compilación")
  end

  desc "Construye la imagen y ejecuta la compilación en un solo paso"
  task run: [:build, :compile]

  desc "Elimina la imagen Docker de compilación"
  task :clean do
    system("docker compose down --rmi local", chdir: DOCKER_BUILD_DIR)
  end
end
