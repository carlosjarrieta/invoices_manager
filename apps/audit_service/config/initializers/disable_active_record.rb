# Deshabilitar ActiveRecord explícitamente
# Este servicio usa solo Mongoid para MongoDB

Rails.application.config.before_initialize do
  # No cargar railtie de ActiveRecord
  ActiveSupport.on_load(:active_record) do
    # Esto nunca debería ejecutarse
    raise "ActiveRecord no debería cargarse en audit_service"
  end
end
