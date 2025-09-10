class CreateDefaultAdminUser < ActiveRecord::Migration[8.0]
  def up
    # Create a default admin user if no admin exists
    unless User.exists?(role: 'admin')
      User.create!(
        username: 'admin',
        name: 'System Administrator',
        role: 'admin',
        password: 'admin123',
        password_confirmation: 'admin123'
      )
      puts "Default admin user created:"
      puts "Username: admin"
      puts "Password: admin123"
      puts "Please change the password after first login!"
    end
  end

  def down
    # Remove the default admin user if it still has default credentials
    admin = User.find_by(username: 'admin', role: 'admin')
    if admin&.valid_password?('admin123')
      admin.destroy
      puts "Default admin user removed"
    end
  end
end
