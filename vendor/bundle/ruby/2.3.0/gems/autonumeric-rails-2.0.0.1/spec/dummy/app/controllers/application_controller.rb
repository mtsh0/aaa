class ApplicationController < ActionController::Base
  def self.create_action(name)
    define_method(name) do
      send :without_record
      render action: name
    end

    define_method("#{name}_with_record".to_sym) do
      send :with_record
      render action: name
    end
  end
end
