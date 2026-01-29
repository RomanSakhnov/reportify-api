# Seed data for Reportify API
# Run: rails db:seed

puts '🌱 Seeding database...'

# Clear existing data (optional - comment out if you want to keep existing data)
puts 'Clearing existing data...'
Item.destroy_all
User.destroy_all
ReportDatum.destroy_all

# Create admin user
puts 'Creating admin user...'
admin = User.create!(
  name: 'Admin User',
  email: 'admin@reportify.com',
  password: 'password123',
  role: 'admin',
  active: true
)
puts "✓ Admin created: #{admin.email}"

# Create regular users
puts 'Creating regular users...'
users = []
10.times do
  user = User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.unique.email,
    password: 'password123',
    role: 'user',
    active: true
  )
  users << user
end
puts "✓ Created #{users.count} regular users"

# Create items for users
puts 'Creating items...'
items_count = 0
users.each do |user|
  rand(3..8).times do
    Item.create!(
      user: user,
      name: Faker::Commerce.product_name,
      description: Faker::Lorem.paragraph(sentence_count: 2),
      category: Item::CATEGORIES.sample,
      price: Faker::Commerce.price(range: 10.0..500.0),
      quantity: Faker::Number.between(from: 0, to: 100),
      active: [true, true, true, false].sample # 75% active
    )
    items_count += 1
  end
end
puts "✓ Created #{items_count} items"

# Create some items for admin
rand(5..10).times do
  Item.create!(
    user: admin,
    name: Faker::Commerce.product_name,
    description: Faker::Lorem.paragraph(sentence_count: 2),
    category: Item::CATEGORIES.sample,
    price: Faker::Commerce.price(range: 10.0..500.0),
    quantity: Faker::Number.between(from: 0, to: 100),
    active: true
  )
  items_count += 1
end

# Generate report data for the last 30 days
puts 'Generating report data for the last 30 days...'
report_count = 0
30.times do |i|
  date = (Date.today - i.days)

  # Daily metrics
  ReportDatum.create!(
    report_type: 'daily_metrics',
    date: date,
    data: {
      page_views: Faker::Number.between(from: 1000, to: 5000),
      unique_visitors: Faker::Number.between(from: 500, to: 2000),
      avg_session_duration: Faker::Number.between(from: 120, to: 600),
      bounce_rate: Faker::Number.decimal(l_digits: 2, r_digits: 2).to_f,
      conversion_rate: Faker::Number.decimal(l_digits: 1, r_digits: 2).to_f
    }
  )

  # User activity
  ReportDatum.create!(
    report_type: 'user_activity',
    date: date,
    data: {
      new_users: Faker::Number.between(from: 5, to: 50),
      active_users: Faker::Number.between(from: 100, to: 500),
      user_sessions: Faker::Number.between(from: 200, to: 1000),
      avg_actions_per_user: Faker::Number.between(from: 5, to: 25)
    }
  )

  # Item sales
  sales_by_category = Item::CATEGORIES.each_with_object({}) do |category, hash|
    hash[category] = {
      units_sold: Faker::Number.between(from: 10, to: 100),
      revenue: Faker::Number.decimal(l_digits: 4, r_digits: 2).to_f
    }
  end

  ReportDatum.create!(
    report_type: 'item_sales',
    date: date,
    data: {
      total_sales: Faker::Number.between(from: 100, to: 500),
      total_revenue: Faker::Number.decimal(l_digits: 5, r_digits: 2).to_f,
      avg_order_value: Faker::Number.decimal(l_digits: 3, r_digits: 2).to_f,
      by_category: sales_by_category
    }
  )

  report_count += 3
end
puts "✓ Created #{report_count} report data entries"

puts "\n✨ Seeding completed!"
puts "\n📊 Summary:"
puts "  Users: #{User.count}"
puts "  Items: #{Item.count}"
puts "  Report Data: #{ReportDatum.count}"
puts "\n🔑 Login credentials:"
puts '  Admin: admin@reportify.com / password123'
puts "  User: #{users.first.email} / password123"
