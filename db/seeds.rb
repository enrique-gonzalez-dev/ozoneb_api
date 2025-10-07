# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create default admin user
admin_user = User.find_or_create_by!(email: 'admin@ozoneb.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.name = 'Admin'
  user.last_name = 'User'
  user.role = 'admin'
end

puts "Created admin user: #{admin_user.email}" if admin_user.persisted?

# Create initial admin user
admin_user = User.find_or_create_by!(email: "admin@ozoneb.com") do |user|
  user.name = "Admin"
  user.last_name = "User"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :admin
end

puts "Created admin user: #{admin_user.email}"
puts "Password: password123"
puts "Role: #{admin_user.role}"
