# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
puts 'Destroying users...'
User.destroy_all

puts 'Destroying activities...'
Activity.destroy_all

puts 'Seeding user...'
user = User.new(email_address: 'user@example.com')
user.password = '123456'
user.save!

puts 'Seeding activities...'
5.times do
  Activity.create(name: Faker::Hobby.unique.activity, user: user)
end
