# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Starting seed process..."

# Create default admin user
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
