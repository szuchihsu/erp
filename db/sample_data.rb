# Comprehensive sample data for ERP system
# Run with: rails runner db/sample_data.rb
# This file combines user creation and all sample data

puts "Creating comprehensive sample data for ERP system..."

# CREATE ADMIN USER FIRST
puts "\nCreating admin user..."
unless User.find_by(username: 'admin')
  User.create!(
    username: 'admin',
    name: 'System Administrator',
    role: 'admin',
    password: 'admin123',
    password_confirmation: 'admin123'
  )
  puts "Created admin user: admin/admin123"
else
  puts "Admin user already exists"
end

# 0. USERS FOR RBAC TESTING
puts "\nCreating sample users for RBAC testing..."

# Create users with different roles (skip if already exist)
unless User.where.not(role: 'admin').exists?
  # Find some employees to link to users (will be created below if they don't exist)
  # We'll link users after employees are created

  users_data = [
    { username: "manager", name: "Sarah Johnson", role: "manager" },
    { username: "supervisor", name: "David Rodriguez", role: "supervisor" },
    { username: "worker", name: "Lisa Thompson", role: "production_worker" },
    { username: "inventory", name: "Kevin Walsh", role: "inventory_clerk" },
    { username: "sales", name: "Jennifer Davis", role: "sales_rep" },
    { username: "designer", name: "Emily Zhang", role: "designer" },
    { username: "quality", name: "Maria Garcia", role: "quality_control" }
  ]

  users_data.each do |user_data|
    User.create!(
      username: user_data[:username],
      name: user_data[:name],
      role: user_data[:role],
      password: "password123",
      password_confirmation: "password123"
    )
  end

  puts "Created #{User.where.not(role: 'admin').count} sample users"
  puts "Sample users created for testing RBAC:"
  puts "Admin: admin/admin123"
  puts "Manager: manager/password123"
  puts "Supervisor: supervisor/password123"
  puts "Production Worker: worker/password123"
  puts "Inventory Clerk: inventory/password123"
  puts "Sales Rep: sales/password123"
  puts "Designer: designer/password123"
  puts "Quality Control: quality/password123"
  puts "All users have access to different parts of the system based on their roles."
else
  puts "Sample users already exist, skipping user creation"
end

# 1. CUSTOMERS
puts "\nCreating sample customers..."

customers_data = [
  {
    customer_id: "CUST001",
    name: "TechCorp Solutions",
    email: "orders@techcorp.com",
    phone: "+1-555-0101",
    address: "123 Innovation Drive, Tech Valley, CA 94000",
    customer_type: "wholesale",
    status: "active"
  },
  {
    customer_id: "CUST002",
    name: "Global Manufacturing Inc.",
    email: "procurement@globalmfg.com",
    phone: "+1-555-0202",
    address: "456 Industrial Blvd, Manufacturing City, TX 75001",
    customer_type: "wholesale",
    status: "active"
  },
  {
    customer_id: "CUST003",
    name: "Retail Plus Store",
    email: "buyer@retailplus.com",
    phone: "+1-555-0303",
    address: "789 Commerce Street, Retail Town, NY 10001",
    customer_type: "retail",
    status: "active"
  },
  {
    customer_id: "CUST004",
    name: "Premium Partners LLC",
    email: "vip@premiumpartners.com",
    phone: "+1-555-0404",
    address: "321 Executive Plaza, Business District, FL 33101",
    customer_type: "vip",
    status: "active"
  },
  {
    customer_id: "CUST005",
    name: "StartUp Dynamics",
    email: "founder@startupd.com",
    phone: "+1-555-0505",
    address: "654 Innovation Hub, Silicon Valley, CA 94301",
    customer_type: "retail",
    status: "active"
  },
  {
    customer_id: "CUST006",
    name: "Enterprise Solutions Corp",
    email: "purchasing@enterprise.com",
    phone: "+1-555-0606",
    address: "987 Corporate Center, Business Park, IL 60601",
    customer_type: "wholesale",
    status: "active"
  },
  {
    customer_id: "CUST007",
    name: "Boutique Retail Co.",
    email: "manager@boutique.com",
    phone: "+1-555-0707",
    address: "147 Fashion Avenue, Style City, NY 10018",
    customer_type: "retail",
    status: "active"
  }
]

customers_data.each do |customer_data|
  Customer.find_or_create_by(customer_id: customer_data[:customer_id]) do |customer|
    customer.assign_attributes(customer_data)
  end
end

puts "Created #{Customer.count} customers"

# 2. EMPLOYEES (Enhanced)
puts "\nCreating sample employees..."

employees_data = [
  # Management
  { employee_id: "EMP001", name: "Sarah Johnson", department: "management", position: "General Manager", status: "active", email: "sarah.johnson@company.com", phone: "+1-555-1001", salary: 95000.00, hire_date: Date.new(2020, 3, 15) },
  { employee_id: "EMP002", name: "Michael Chen", department: "admin", position: "Operations Director", status: "active", email: "michael.chen@company.com", phone: "+1-555-1002", salary: 85000.00, hire_date: Date.new(2019, 8, 22) },

  # Production
  { employee_id: "EMP003", name: "David Rodriguez", department: "production", position: "Production Supervisor", status: "active", email: "david.rodriguez@company.com", phone: "+1-555-2001", salary: 65000.00, hire_date: Date.new(2021, 1, 10) },
  { employee_id: "EMP004", name: "Lisa Thompson", department: "production", position: "Production Worker", status: "active", email: "lisa.thompson@company.com", phone: "+1-555-2002", salary: 45000.00, hire_date: Date.new(2022, 6, 5) },
  { employee_id: "EMP005", name: "James Wilson", department: "production", position: "Production Worker", status: "active", email: "james.wilson@company.com", phone: "+1-555-2003", salary: 47000.00, hire_date: Date.new(2021, 11, 18) },
  { employee_id: "EMP006", name: "Maria Garcia", department: "quality", position: "Quality Control Specialist", status: "active", email: "maria.garcia@company.com", phone: "+1-555-2004", salary: 55000.00, hire_date: Date.new(2020, 9, 12) },
  { employee_id: "EMP007", name: "Robert Kim", department: "production", position: "Machine Operator", status: "active", email: "robert.kim@company.com", phone: "+1-555-2005", salary: 52000.00, hire_date: Date.new(2022, 2, 28) },

  # Sales
  { employee_id: "EMP008", name: "Jennifer Davis", department: "sales", position: "Sales Manager", status: "active", email: "jennifer.davis@company.com", phone: "+1-555-3001", salary: 75000.00, hire_date: Date.new(2019, 5, 20) },
  { employee_id: "EMP009", name: "Thomas Anderson", department: "sales", position: "Sales Representative", status: "active", email: "thomas.anderson@company.com", phone: "+1-555-3002", salary: 48000.00, hire_date: Date.new(2021, 7, 14) },
  { employee_id: "EMP010", name: "Ashley Martinez", department: "sales", position: "Sales Representative", status: "active", email: "ashley.martinez@company.com", phone: "+1-555-3003", salary: 50000.00, hire_date: Date.new(2022, 3, 8) },
  { employee_id: "EMP011", name: "Daniel Lee", department: "sales", position: "Account Manager", status: "active", email: "daniel.lee@company.com", phone: "+1-555-3004", salary: 58000.00, hire_date: Date.new(2020, 12, 1) },

  # Design
  { employee_id: "EMP012", name: "Emily Zhang", department: "design", position: "Lead Designer", status: "active", email: "emily.zhang@company.com", phone: "+1-555-4001", salary: 72000.00, hire_date: Date.new(2019, 10, 15) },
  { employee_id: "EMP013", name: "Christopher Brown", department: "design", position: "Product Designer", status: "active", email: "christopher.brown@company.com", phone: "+1-555-4002", salary: 62000.00, hire_date: Date.new(2021, 4, 25) },
  { employee_id: "EMP014", name: "Amanda Taylor", department: "design", position: "Graphic Designer", status: "active", email: "amanda.taylor@company.com", phone: "+1-555-4003", salary: 55000.00, hire_date: Date.new(2022, 1, 12) },

  # Inventory
  { employee_id: "EMP015", name: "Kevin Walsh", department: "inventory", position: "Inventory Manager", status: "active", email: "kevin.walsh@company.com", phone: "+1-555-5001", salary: 60000.00, hire_date: Date.new(2020, 7, 8) },
  { employee_id: "EMP016", name: "Rachel Cooper", department: "inventory", position: "Inventory Clerk", status: "active", email: "rachel.cooper@company.com", phone: "+1-555-5002", salary: 42000.00, hire_date: Date.new(2021, 9, 20) },
  { employee_id: "EMP017", name: "Brandon Scott", department: "inventory", position: "Warehouse Coordinator", status: "active", email: "brandon.scott@company.com", phone: "+1-555-5003", salary: 45000.00, hire_date: Date.new(2022, 5, 16) }
]

employees_data.each do |employee_data|
  Employee.find_or_create_by(employee_id: employee_data[:employee_id]) do |employee|
    employee.assign_attributes(employee_data)
  end
end

puts "Created #{Employee.count} employees"

# 3. MATERIALS
puts "\nCreating sample materials..."

materials_data = [
  # Precious Metals
  {
    name: "Sterling Silver Wire 20GA",
    code: "MAT-AG001",
    description: "925 sterling silver wire, 20 gauge, dead soft",
    category: "precious_metal",
    subcategory: "Silver Wire",
    unit_of_measure: "inch",
    current_cost: 0.85,
    current_stock: 1200,
    minimum_stock: 200,
    supplier: "Precious Metal Supply Co",
    is_active: true
  },
  {
    name: "14K Yellow Gold Sheet",
    code: "MAT-AU002",
    description: "14 karat yellow gold sheet, 18 gauge thickness",
    category: "precious_metal",
    subcategory: "Gold Sheet",
    unit_of_measure: "square_inch",
    current_cost: 45.75,
    current_stock: 85,
    minimum_stock: 15,
    supplier: "Gold Refiners LLC",
    is_active: true
  },
  {
    name: "Copper Wire 16GA",
    code: "MAT-CU003",
    description: "Pure copper wire, 16 gauge, half hard temper",
    category: "precious_metal",
    subcategory: "Copper Wire",
    unit_of_measure: "foot",
    current_cost: 0.12,
    current_stock: 2500,
    minimum_stock: 500,
    supplier: "Base Metal Works",
    is_active: true
  },
  {
    name: "Platinum Round Wire",
    code: "MAT-PT004",
    description: "950 platinum round wire, 18 gauge",
    category: "precious_metal",
    subcategory: "Platinum Wire",
    unit_of_measure: "inch",
    current_cost: 12.50,
    current_stock: 150,
    minimum_stock: 25,
    supplier: "Platinum Solutions",
    is_active: true
  },

  # Gemstones
  {
    name: "Natural Diamond - Round 1ct",
    code: "MAT-DIA005",
    description: "Natural diamond, round brilliant cut, 1 carat, VS1 clarity, G color",
    category: "gemstone",
    subcategory: "Diamonds",
    unit_of_measure: "piece",
    current_cost: 4500.00,
    current_stock: 12,
    minimum_stock: 3,
    supplier: "Diamond Direct Import",
    is_active: true
  },
  {
    name: "Blue Sapphire Oval",
    code: "MAT-SAP006",
    description: "Natural blue sapphire, oval cut, 2x3mm",
    category: "gemstone",
    subcategory: "Colored Stones",
    unit_of_measure: "piece",
    current_cost: 125.00,
    current_stock: 45,
    minimum_stock: 10,
    supplier: "Colored Stone Gallery",
    is_active: true
  },
  {
    name: "Ruby Cabochon 6mm",
    code: "MAT-RUB007",
    description: "Natural ruby cabochon, 6mm round",
    category: "gemstone",
    subcategory: "Colored Stones",
    unit_of_measure: "piece",
    current_cost: 89.00,
    current_stock: 28,
    minimum_stock: 8,
    supplier: "Gemstone Wholesalers",
    is_active: true
  },
  {
    name: "Pearl Freshwater 8mm",
    code: "MAT-PRL008",
    description: "Freshwater cultured pearl, white, 8mm round",
    category: "gemstone",
    subcategory: "Pearls",
    unit_of_measure: "piece",
    current_cost: 15.50,
    current_stock: 200,
    minimum_stock: 50,
    supplier: "Pearl Harvest Co",
    is_active: true
  },

  # Findings
  {
    name: "Sterling Silver Jump Rings",
    code: "MAT-JMP009",
    description: "Sterling silver jump rings, 6mm open",
    category: "finding",
    subcategory: "Jump Rings",
    unit_of_measure: "piece",
    current_cost: 0.25,
    current_stock: 1000,
    minimum_stock: 200,
    supplier: "Findings Plus",
    is_active: true
  },
  {
    name: "Gold Filled Ear Wires",
    code: "MAT-EAR010",
    description: "14k gold filled ear wires, French hook style",
    category: "finding",
    subcategory: "Ear Wires",
    unit_of_measure: "pair",
    current_cost: 2.85,
    current_stock: 500,
    minimum_stock: 100,
    supplier: "Gold Filled Supply",
    is_active: true
  },
  {
    name: "Silver Prong Settings",
    code: "MAT-SET011",
    description: "Sterling silver 4-prong settings for 6mm stones",
    category: "finding",
    subcategory: "Settings",
    unit_of_measure: "piece",
    current_cost: 4.25,
    current_stock: 150,
    minimum_stock: 30,
    supplier: "Setting Solutions",
    is_active: true
  },
  {
    name: "Chain - Cable Link Silver",
    code: "MAT-CHN012",
    description: "Sterling silver cable chain, 2mm link",
    category: "finding",
    subcategory: "Chain",
    unit_of_measure: "foot",
    current_cost: 3.50,
    current_stock: 500,
    minimum_stock: 100,
    supplier: "Chain Masters",
    is_active: true
  },

  # Tools
  {
    name: "Jewelers Saw Blades",
    code: "MAT-SAW013",
    description: "Jewelers saw blades, size 2/0, pack of 12",
    category: "tool",
    subcategory: "Cutting Tools",
    unit_of_measure: "pack",
    current_cost: 8.95,
    current_stock: 25,
    minimum_stock: 5,
    supplier: "Jewelry Tool Supply",
    is_active: true
  },
  {
    name: "Ring Mandrel Steel",
    code: "MAT-MAN014",
    description: "Steel ring mandrel with size markings",
    category: "tool",
    subcategory: "Forming Tools",
    unit_of_measure: "piece",
    current_cost: 45.00,
    current_stock: 8,
    minimum_stock: 2,
    supplier: "Professional Tools Inc",
    is_active: true
  },

  # Consumables
  {
    name: "Polishing Compound - Rouge",
    code: "MAT-POL015",
    description: "Red rouge polishing compound for final polish",
    category: "consumable",
    subcategory: "Polishing",
    unit_of_measure: "stick",
    current_cost: 6.50,
    current_stock: 50,
    minimum_stock: 10,
    supplier: "Polish Pro Supply",
    is_active: true
  },
  {
    name: "Pickle Solution",
    code: "MAT-PCK016",
    description: "Safety pickle for cleaning oxidized metals",
    category: "consumable",
    subcategory: "Cleaning",
    unit_of_measure: "pound",
    current_cost: 12.75,
    current_stock: 20,
    minimum_stock: 5,
    supplier: "Chemical Solutions",
    is_active: true
  },

  # Packaging
  {
    name: "Jewelry Gift Boxes",
    code: "MAT-BOX017",
    description: "White jewelry gift boxes, 3x3x1 inch",
    category: "packaging",
    subcategory: "Gift Boxes",
    unit_of_measure: "piece",
    current_cost: 0.85,
    current_stock: 500,
    minimum_stock: 100,
    supplier: "Package Perfect",
    is_active: true
  },
  {
    name: "Tissue Paper Sheets",
    code: "MAT-TSU018",
    description: "White tissue paper for jewelry packaging",
    category: "packaging",
    subcategory: "Wrapping",
    unit_of_measure: "sheet",
    current_cost: 0.05,
    current_stock: 2000,
    minimum_stock: 500,
    supplier: "Paper Plus Supply",
    is_active: true
  }
]

materials_data.each do |material_data|
  Material.find_or_create_by(code: material_data[:code]) do |material|
    material.assign_attributes(material_data)
  end
end

puts "Created #{Material.count} materials"

# 4. PRODUCTS
puts "\nCreating sample products..."

products_data = [
  {
    product_id: "PROD-RNG001",
    name: "Diamond Solitaire Ring",
    description: "Classic 14k white gold solitaire ring with 1ct diamond center stone",
    category: "rings",
    cost_price: 4800.00,
    selling_price: 7200.00,
    stock_quantity: 8,
    minimum_stock_level: 2,
    supplier: "Fine Jewelry Creations",
    status: "active",
    reorder_point: 3,
    optimal_stock_level: 12
  },
  {
    product_id: "PROD-NCK002",
    name: "Pearl Strand Necklace",
    description: "18-inch freshwater pearl necklace with sterling silver clasp",
    category: "necklaces",
    cost_price: 185.00,
    selling_price: 350.00,
    stock_quantity: 15,
    minimum_stock_level: 5,
    supplier: "Pearl Designs Inc",
    status: "active",
    reorder_point: 7,
    optimal_stock_level: 25
  },
  {
    product_id: "PROD-EAR003",
    name: "Sapphire Stud Earrings",
    description: "Blue sapphire stud earrings in 14k yellow gold setting",
    category: "earrings",
    cost_price: 425.00,
    selling_price: 680.00,
    stock_quantity: 12,
    minimum_stock_level: 3,
    supplier: "Colored Stone Studio",
    status: "active",
    reorder_point: 5,
    optimal_stock_level: 18
  },
  {
    product_id: "PROD-BRC004",
    name: "Silver Tennis Bracelet",
    description: "Sterling silver tennis bracelet with CZ stones",
    category: "bracelets",
    cost_price: 95.00,
    selling_price: 165.00,
    stock_quantity: 20,
    minimum_stock_level: 6,
    supplier: "Silver Elegance Co",
    status: "active",
    reorder_point: 8,
    optimal_stock_level: 30
  },
  {
    product_id: "PROD-PND005",
    name: "Ruby Heart Pendant",
    description: "Heart-shaped ruby pendant with diamond accent in white gold",
    category: "pendants",
    cost_price: 650.00,
    selling_price: 975.00,
    stock_quantity: 6,
    minimum_stock_level: 2,
    supplier: "Heart Collection Ltd",
    status: "active",
    reorder_point: 3,
    optimal_stock_level: 10
  },
  {
    product_id: "PROD-CHN006",
    name: "Gold Figaro Chain",
    description: "18-inch 14k gold figaro chain, 4mm width",
    category: "necklaces",
    cost_price: 485.00,
    selling_price: 725.00,
    stock_quantity: 10,
    minimum_stock_level: 3,
    supplier: "Chain Masters Inc",
    status: "active",
    reorder_point: 4,
    optimal_stock_level: 15
  },
  {
    product_id: "PROD-WED007",
    name: "Wedding Band Set",
    description: "His and hers matching wedding band set in 14k white gold",
    category: "rings",
    cost_price: 380.00,
    selling_price: 580.00,
    stock_quantity: 12,
    minimum_stock_level: 4,
    supplier: "Wedding Collection Co",
    status: "active",
    reorder_point: 6,
    optimal_stock_level: 20
  },
  {
    product_id: "PROD-BRO008",
    name: "Vintage Flower Brooch",
    description: "Art deco inspired flower brooch with emerald and diamond details",
    category: "pendants",
    cost_price: 1250.00,
    selling_price: 1875.00,
    stock_quantity: 4,
    minimum_stock_level: 1,
    supplier: "Vintage Reproductions",
    status: "active",
    reorder_point: 2,
    optimal_stock_level: 6
  },
  {
    product_id: "PROD-CUF009",
    name: "Silver Cufflinks",
    description: "Sterling silver cufflinks with onyx inlay",
    category: "rings",
    cost_price: 85.00,
    selling_price: 145.00,
    stock_quantity: 18,
    minimum_stock_level: 5,
    supplier: "Gentleman's Choice",
    status: "active",
    reorder_point: 7,
    optimal_stock_level: 25
  },
  {
    product_id: "PROD-ANK010",
    name: "Gold Anklet Chain",
    description: "Delicate 10k gold anklet with heart charm",
    category: "bracelets",
    cost_price: 125.00,
    selling_price: 195.00,
    stock_quantity: 14,
    minimum_stock_level: 4,
    supplier: "Summer Jewelry Co",
    status: "active",
    reorder_point: 6,
    optimal_stock_level: 20
  },
  {
    product_id: "PROD-SET011",
    name: "Jewelry Gift Set",
    description: "Matching necklace and earring set with amethyst stones",
    category: "necklaces",
    cost_price: 165.00,
    selling_price: 285.00,
    stock_quantity: 9,
    minimum_stock_level: 3,
    supplier: "Gift Set Specialists",
    status: "active",
    reorder_point: 4,
    optimal_stock_level: 15
  },
  {
    product_id: "PROD-CHM012",
    name: "Charm Bracelet",
    description: "Sterling silver charm bracelet with 5 starter charms",
    category: "bracelets",
    cost_price: 95.00,
    selling_price: 165.00,
    stock_quantity: 16,
    minimum_stock_level: 5,
    supplier: "Charm Collection Ltd",
    status: "active",
    reorder_point: 7,
    optimal_stock_level: 24
  }
]

products_data.each do |product_data|
  Product.find_or_create_by(product_id: product_data[:product_id]) do |product|
    product.assign_attributes(product_data)
  end
end

puts "Created #{Product.count} products"

# 5. LINK USERS WITH EMPLOYEES
puts "\nLinking users with employees..."

user_employee_links = {
  "manager" => "Sarah Johnson",      # General Manager
  "supervisor" => "David Rodriguez", # Production Supervisor
  "worker" => "Lisa Thompson",       # Production Worker
  "inventory" => "Kevin Walsh",      # Inventory Manager
  "sales" => "Jennifer Davis",       # Sales Manager
  "designer" => "Emily Zhang",       # Lead Designer
  "quality" => "Maria Garcia"        # Quality Control Specialist
}

user_employee_links.each do |username, employee_name|
  user = User.find_by(username: username)
  employee = Employee.find_by(name: employee_name)

  if user && employee && !user.employee_id
    user.update!(employee: employee)
    puts "Linked user '#{username}' with employee '#{employee_name}'"
  end
end

puts "\n✅ Sample data creation completed!"
puts "\nSummary:"
puts "- Users: #{User.count}"
puts "- Customers: #{Customer.count}"
puts "- Employees: #{Employee.count}"
puts "- Materials: #{Material.count}"
puts "- Products: #{Product.count}"

puts "\nTo view the data, visit:"
puts "- Users: http://localhost:3000/users (admin access required)"
puts "- Customers: http://localhost:3000/customers"
puts "- Employees: http://localhost:3000/employees"
puts "- Materials: http://localhost:3000/materials"
puts "- Products: http://localhost:3000/products"

puts "\nLogin credentials for testing:"
puts "- Admin: admin/admin123"
puts "- Manager: manager/password123"
puts "- Supervisor: supervisor/password123"
puts "- Production Worker: worker/password123"
puts "- Inventory Clerk: inventory/password123"
puts "- Sales Rep: sales/password123"
puts "- Designer: designer/password123"
puts "- Quality Control: quality/password123"
