# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Load sample data for demonstration and testing
puts "Loading sample data..."

# Execute the sample data script
load Rails.root.join('db', 'sample_data.rb')

puts "Sample data loaded successfully!"
