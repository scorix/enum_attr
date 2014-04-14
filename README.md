# enum_attr

This is a gem for adding enum attributes to classes.

## Dependencies

* [activesupport](https://github.com/rails/rails/tree/master/activesupport)

## Installation

Add this line to your application's Gemfile:

    gem 'enum_attr', github: 'scorix/enum_attr'

And then execute:

    $ bundle

## Usage

```ruby
class Package
  # enum_attr :status, {out_of_stock: -1, ready: 0, selling: 1}, default: 0

  # or you can use symbol as default value
  enum_attr :status, {out_of_stock: -1, ready: 0, selling: 1}, default: :ready
end

package = Package.new
package.status              # => 0
package.ready?              # => true
package.out_of_stock!       # => -1
package.ready?              # => false
package.status              # => -1
Package.available_statuses  # => {out_of_stock: -1, ready: 0, selling: 1}
package.available_statuses  # => {out_of_stock: -1, ready: 0, selling: 1}
```

or you can use array, too

```ruby
class Package
  # enum_attr :status, [-1, 0, 1]

  # you can also specify a default value
  # NOTIFICATION: default value a real value, not index of array
  enum_attr :status, [-1, 0, 1], default: 0
end

package = Package.new
package.status              # => 0
Package.available_statuses  # => [-1, 0, 1]
package.available_statuses  # => [-1, 0, 1]
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
