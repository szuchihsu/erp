module AuthorizationHelper
  # Check if current user can see a link/button
  def can_see_link?(permission_check)
    return false unless current_user

    case permission_check
    when :manage_users
      current_user.can_manage_users?
    when :manage_employees
      current_user.can_manage_employees?
    when :manage_production
      current_user.can_manage_production?
    when :work_orders
      current_user.can_work_on_orders?
    when :manage_inventory
      current_user.can_manage_inventory?
    when :create_sales_orders
      current_user.can_create_sales_orders?
    when :manage_customers
      current_user.can_manage_customers?
    when :manage_materials
      current_user.can_manage_materials?
    when :manage_products
      current_user.can_manage_products?
    when :manage_designs
      current_user.can_manage_designs?
    when :view_reports
      current_user.can_view_reports?
    when :view_financial
      current_user.can_view_financial_data?
    when :quality_control
      current_user.can_quality_control?
    when :supervisor_access
      current_user.supervisor?
    when :manager_access
      current_user.manager?
    when :admin_access
      current_user.admin?
    else
      false
    end
  end

  # Generate role-based navigation links
  def role_based_nav_links
    links = []

    # Dashboard (everyone can see)
    links << { name: "Dashboard", path: root_path, icon: "🏠" }

    # Sales & Customer Management
    if can_see_link?(:supervisor_access)
      links << { name: "Sales Orders", path: sales_orders_path, icon: "📋" }
      links << { name: "Customers", path: customers_path, icon: "👥" }
    end

    # Production Management
    if can_see_link?(:supervisor_access)
      links << { name: "Production Orders", path: production_orders_path, icon: "🏭" }
    end

    # Inventory Management
    if can_see_link?(:supervisor_access)
      links << { name: "Inventory", path: inventory_path, icon: "📦" }
      links << { name: "Materials", path: materials_path, icon: "🔧" }
      links << { name: "Products", path: products_path, icon: "📱" }
    end

    # Employee Management
    if can_see_link?(:supervisor_access)
      links << { name: "Employees", path: employees_path, icon: "👷" }
    end

    # Design Management
    if can_see_link?(:supervisor_access)
      links << { name: "Design Requests", path: design_requests_path, icon: "🎨" }
    end

    # Admin Only
    if can_see_link?(:admin_access)
      links << { name: "System Admin", path: "#", icon: "⚙️" }
    end

    links
  end

  # Check if user can perform specific action on resource
  def can_perform_action?(action, resource_type)
    return false unless current_user

    case resource_type
    when :sales_order
      case action
      when :create, :edit, :delete
        current_user.can_create_sales_orders?
      when :view
        current_user.supervisor?
      end
    when :production_order
      case action
      when :create, :edit, :delete, :start, :complete
        current_user.can_manage_production?
      when :view
        current_user.supervisor?
      end
    when :employee
      case action
      when :create, :edit, :delete
        current_user.can_manage_employees?
      when :view
        current_user.supervisor?
      end
    when :customer
      case action
      when :create, :edit, :delete
        current_user.can_manage_customers?
      when :view
        current_user.supervisor?
      end
    else
      false
    end
  end
end
