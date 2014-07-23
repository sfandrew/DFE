module DynamicFormsEngine
  class Engine < ::Rails::Engine
    isolate_namespace DynamicFormsEngine

    # Auto-load decorators in the host app's decorators directory, e.g. for overriding or extending this engine's models and controllers
    config.to_prepare do
      Dir.glob(Rails.root + "app/decorators/**/*_decorator*.rb").each do |c|
        require_dependency(c)
      end
    end
  end
end
