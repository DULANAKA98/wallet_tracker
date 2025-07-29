# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create sample users
puts "Creating sample users..."

user1 = User.find_or_create_by(email: 'john@example.com') do |user|
  user.name = 'Ahmad Rahman'
  user.credit = 100.0
end

user2 = User.find_or_create_by(email: 'jane@example.com') do |user|
  user.name = 'Siti Aminah'
  user.credit = 250.0
end

puts "Created users: #{user1.name} (#{user1.email}) with #{user1.credit} credits"
puts "Created users: #{user2.name} (#{user2.email}) with #{user2.credit} credits"

# Create sample products
puts "Creating sample products..."

products = [
  { name: 'iPhone 15 Pro', price: 999.99, description: 'Latest iPhone with advanced features', image_url: 'https://via.placeholder.com/300x300?text=iPhone+15+Pro' },
  { name: 'MacBook Air M2', price: 1199.99, description: 'Powerful laptop with M2 chip', image_url: 'https://via.placeholder.com/300x300?text=MacBook+Air+M2' },
  { name: 'AirPods Pro', price: 249.99, description: 'Wireless earbuds with noise cancellation', image_url: 'https://via.placeholder.com/300x300?text=AirPods+Pro' },
  { name: 'iPad Air', price: 599.99, description: 'Versatile tablet for work and play', image_url: 'https://via.placeholder.com/300x300?text=iPad+Air' },
  { name: 'Apple Watch Series 9', price: 399.99, description: 'Smartwatch with health tracking', image_url: 'https://via.placeholder.com/300x300?text=Apple+Watch+Series+9' }
]

products.each do |product_data|
  product = Product.find_or_create_by(name: product_data[:name]) do |p|
    p.price = product_data[:price]
    p.description = product_data[:description]
    p.image_url = product_data[:image_url]
  end
  puts "Created product: #{product.name} - $#{product.price}"
end

puts "Seed data created successfully!"
