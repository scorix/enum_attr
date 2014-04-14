require 'enum_attr/version'
require 'active_support/core_ext/string/inflections'
require 'active_support/callbacks'

module EnumAttr

  ##
  #  example:
  #
  #    class Package
  #      enum_attr :status, {out_of_stock: -1, ready: 0, selling: 1}, default: 0
  #
  #      # or you can use symbol as default value
  #      enum_attr :status, {out_of_stock: -1, ready: 0, selling: 1}, default: :ready
  #    end
  #
  #    package = Package.new
  #    package.status              # => 0
  #    package.ready?              # => true
  #    package.out_of_stock!       # => -1
  #    package.ready?              # => false
  #    package.status              # => -1
  #

  def enum_attr(*args)
    field, values, options = args

    # define method :[status]
    _define_getter_method(field)

    # define method :[status=]
    _define_setter_method(field)

    # define class and instance method :available_[statuses]
    define_singleton_method("available_#{field.to_s.pluralize}".to_sym) { values }
    define_method("available_#{field.to_s.pluralize}".to_sym) { values }

    # set default value
    default = (options || { default: nil }).fetch(:default, nil)
    if values.is_a? Hash
      _initialize_instance(field, values.fetch(default, default), options)
      _def_hash_enum_attr_methods(field)
    elsif values.is_a? Array
      _initialize_instance(field, default, options)
    end
  end

  ##
  #  private method
  #
  #    define setter method for enum_attr
  #
  def _define_setter_method(field)
    if respond_to?("#{field}=".to_sym)
      origin_setter_method_name = "__origin__#{field}=".to_sym
      alias_method origin_setter_method_name, "#{field}=".to_sym
      define_method("#{field}=".to_sym) do |new_value|
        self.instance_variable_set("@#{field}".to_sym, new_value)
        self.send origin_setter_method_name, new_value
      end
    else
      define_method("#{field}=".to_sym) do |new_value|
        self.instance_variable_set("@#{field}".to_sym, new_value)
      end
    end
  end

  ##
  #  private method
  #
  #    define getter method for enum_attr
  #
  def _define_getter_method(field)
    define_method(field) { self.instance_variable_get("@#{field}".to_sym) } unless respond_to?(field.to_sym)
  end

  ##
  #  private method
  #
  #    run callbacks in the `initialize` method to set default :[status] values
  #
  def _initialize_instance(field, default_value, options)
    unless options.nil?
      # define method :set_default_[status]
      define_method("set_default_#{field}".to_sym) { self.send "#{field}=".to_sym, default_value }

      class_eval do
        include ActiveSupport::Callbacks
        define_callbacks :initialize
        set_callback :initialize, :before, "set_default_#{field}".to_sym

        alias_method :_origin__initialize, :initialize

        def initialize(*args)
          self.send :_origin__initialize, *args
          run_callbacks :initialize
        end
      end
    end
  end

  ##
  #  private method
  #
  #    define methods for hash enum_attr
  #
  #  example:
  #
  #    enum_attr :status, {out_of_stock: -1, ready: 0, selling: 1}, default: :ready
  #
  def _def_hash_enum_attr_methods(field)
    values = self.send "available_#{field.to_s.pluralize}".to_sym

    return unless values.is_a? Hash

    values.each_pair do |key, value|
      # define method :[ready?]
      define_method("#{key}?") { self.send(field.to_sym).eql? value }

      # define method :[ready!]
      define_method("#{key}!") { self.send "#{field}=".to_sym, value }
    end
  end

  private :_define_setter_method, :_define_getter_method, :_initialize_instance, :_def_hash_enum_attr_methods

end

Class.class_eval { include EnumAttr }