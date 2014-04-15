require 'enum_attr/version'
require 'active_support/core_ext/string/inflections'
require 'active_support/callbacks'
require 'active_support/core_ext/module/delegation'

module EnumAttr

  extend ActiveSupport::Concern

  module ClassMethods
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

      class_eval <<-DEF_SETTER_AND_GETTER, __FILE__, __LINE__ + 1
        # define class and instance method :available_[statuses]
        def self.available_#{field.to_s.pluralize}
          #{values}
        end
        delegate :available_#{field.to_s.pluralize}, to: :class

        if defined?(ActiveRecord::Base) && self.superclass.eql?(ActiveRecord::Base)
        else
          # define method :[status=]
          def #{field}=(new_value)
            self.instance_variable_set(:@#{field}, new_value)
          end

          # define method :[status]
          def #{field}
            self.instance_variable_get(:@#{field})
          end
        end
      DEF_SETTER_AND_GETTER

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
    #    run callbacks in the `initialize` method to set default :[status] values
    #
    def _initialize_instance(field, default_value, options)
      unless options.nil?
        # define method :set_default_[status]
        class_eval <<-SET_DEFAULT_VALUES, __FILE__, __LINE__ + 1
          def set_default_#{field}
            self.#{field} ||= #{default_value}
          end

          if defined?(ActiveRecord::Base) && self.superclass.eql?(ActiveRecord::Base)
            after_initialize :set_default_#{field}
          else
            include ActiveSupport::Callbacks
            define_callbacks :initialize
            set_callback :initialize, :after, :set_default_#{field}
            alias_method :_origin__initialize, :initialize

            def initialize(*args)
              self.send :_origin__initialize, *args
              run_callbacks :initialize
            end
          end
        SET_DEFAULT_VALUES
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
        class_eval <<-ATTR_HELPER_METHODS, __FILE__, __LINE__ + 1
          # define method :[ready?]
          def #{key}?
            self.#{field}.eql? #{value}
          end

          # define method :[ready!]
          def #{key}!
            self.update(:#{field} => #{value})
          end

          if defined?(ActiveRecord::Base) && self.superclass.eql?(ActiveRecord::Base)
            # define method :[ready!]
            def #{key}!
              self.update(:#{field} => #{value})
            end
          else
            # define method :[ready!]
            def #{key}!
              self.#{field} = #{value}
            end
          end
        ATTR_HELPER_METHODS
      end
    end

    private :_initialize_instance, :_def_hash_enum_attr_methods

  end
end