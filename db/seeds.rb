# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Starting seed process..."

# Create default admin user

if User.any?
  puts "Users already exist. Skipping users creation."
else
  admin_user = User.find_or_create_by!(email: 'admin@ozoneb.com') do |user|
    user.password = 'password123'
    user.password_confirmation = 'password123'
    user.name = 'Admin'
    user.last_name = 'User'
    user.role = 'admin'
    user.status = 'active'
  end


  puts "Created admin user: #{admin_user.email}" if admin_user.persisted?

  # Crear sucursales de ejemplo
  puts "Creando sucursales..."
  branch_data = [
    ["Sucursal Centro", :production],
    ["Sucursal Norte", :store_only],
    ["Sucursal Sur", :production],
    ["Sucursal Este", :store_only]
  ]
  branches = branch_data.map do |name, type|
    Branch.find_or_create_by!(name: name, branch_type: Branch.branch_types[type])
  end
  puts "Sucursales creadas: #{branches.map(&:name).join(', ')}"

  # Create 20 sample users
  puts "Creating 20 sample users..."

  names = %w[
    Juan María Pedro Ana Luis Carmen José Rosa Miguel Elena
    Carlos Sofia David Laura Alberto Patricia Roberto Claudia
    Fernando Isabel
  ]

  last_names = %w[
    García Rodríguez Martínez López Sánchez Pérez Gómez Martín
    Jiménez Ruiz Hernández Díaz Moreno Muñoz Álvarez Romero
    Alonso Gutiérrez Navarro Torres Domínguez
  ]

  roles = [ :admin, :supervisor, :operation ]
  statuses = [ :active, :inactive ]


  20.times do |i|
    name = names.sample
    last_name = last_names.sample
    email = "user#{i + 1}@ozoneb.com"

    user = User.find_or_create_by!(email: email) do |u|
      u.name = name
      u.last_name = last_name
      u.password = 'password123'
      u.password_confirmation = 'password123'
      u.role = roles.sample
      u.status = statuses.sample
    end

    # Asignar sucursales aleatorias al usuario (1 a todas)
    user.branches = branches.sample(rand(1..branches.size))
    user.save!
    print "."
  end

  puts "\nCreated 20 sample users successfully!"
  puts "All users have the password: password123"
  puts "Admin user: admin@ozoneb.com"
  puts "Sample users: user1@ozoneb.com to user20@ozoneb.com"
  puts "Seed process completed!"
end

if Product.any?
  puts "Products already exist. Skipping products creation."
else
  puts "Creating 50 sample products..."

  50.times do |i|
    product = Product.find_or_create_by!(identifier: "PROD#{1000 + i}") do |p|
      p.name = "Producto #{i + 1}"
      p.unit = ['kg', 'litros', 'unidades'].sample
    end
    print "."
  end

  puts "\nCreated 50 sample products successfully!"
end

if ProductBase.any?
  puts "Product bases already exist. Skipping product bases creation."
else
  puts "Creating 5 sample product bases..."

  5.times do |i|
    product_base = ProductBase.find_or_create_by!(name: "Base de Producto #{i + 1}") do |pb|
      pb.identifier = "BASE#{500 + i}"
      pb.unit = ['kg', 'litros', 'unidades'].sample
    end
    print "."
  end

  puts "\nCreated 5 sample product bases successfully!"
end

if Container.any?
  puts "Containers already exist. Skipping containers creation."
else
  puts "Creating 20 sample containers..."

  20.times do |i|
    container = Container.find_or_create_by!(identifier: "CONT#{2000 + i}") do |c|
      c.name = "Contenedor #{i + 1}"
      c.unit = ['kg', 'litros', 'unidades'].sample
    end
    print "."
  end

  puts "\nCreated 20 sample containers successfully!"
end

if Label.any?
  puts "Labels already exist. Skipping labels creation."
else
  puts "Creating 15 sample labels..."

  15.times do |i|
    label = Label.find_or_create_by!(name: "Etiqueta #{i + 1}") do |l|
      l.identifier = "LABEL#{3000 + i}"
      l.unit = 'pieza'
    end
    print "."
  end

  puts "\nCreated 15 sample labels successfully!"
end


if RawMaterial.any?
  puts "Raw materials already exist. Skipping raw materials creation."
else
  puts "Creating 30 sample raw materials..."

  30.times do |i|
    raw_material = RawMaterial.find_or_create_by!(identifier: "RM#{4000 + i}") do |rm|
      rm.name = "Materia Prima #{i + 1}"
      rm.unit = ['kg', 'litros', 'unidades'].sample
    end
    print "."
  end

  puts "\nCreated 30 sample raw materials successfully!"
end
