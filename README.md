# RelationBuilder

This is a gem for easy build of nested relations through options of initialize

[![Gem Version](https://badge.fury.io/rb/relation_builder.png)](http://badge.fury.io/rb/relation_builder)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'relation_builder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install relation_builder

## Usage

### Examples

Old style of initialize several nested objects:

```ruby
building = Building.new(params)
flat = Flat.new
room = Room.new
bathroom = Bathroom.new
flat.rooms << room
flat.bathroom = bathroom
building.flats << flat
```

Initializing with relation_builder:

```ruby
building = Building.new(params, auto_build_relations: {flats: [:rooms, :bathroom]})
```

### How to install?

In additions to `gem install` you need to

```ruby
include RelationBuilder::InitializeOptions
```

into all models involved in nested build.

## Strategy of relations build

There is two strategy: "nested" and "build". They can be specified by passing
`build_strategy: :build/:nested` into options of initialize.
Bydefault using `:nested` strategy.

### 'Nested' strategy

It use [nested_attributes](http://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html)
for build nested relations. If you have half-filled params. For example, in params you have attributes for building,
flat and room. And suppose that in any case you want to have a bathroom. So you can say same thing as in previous
 example:

```ruby
building = Building.new(params, auto_build_relations: {flat: [:room, :bathroom]})
```

Here you keep all attributes of nested models extracted from params.
And additionally in any case for each flat you get a bathroom.

### 'Build' strategy

It based on simple build association. It can be useful if you doesn't want to have a deal with
[nested_attributes](http://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html).
This strategy has same syntax with `auto_build_relations` key, but have several restrictions.

Positive moments:

* you can build a relations for [ActiveRecord](http://www.rubydoc.info/gems/activerecord/) and
for [Mongoid](https://github.com/mongoid/mongoid).

Negative moments:

* this strategy can't build rest of nesting relation, only full chain, i.e. this strategy is incompatible with
[nested_attributes](http://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html).

## Purpose

One of aim of this gem is easy way to deal with any kind of form_builder (for example, [formtastic](https://github.com/justinfrench/formtastic) ).
If you want to make a form with several nested object you must initialize all objects before send them
into the form. Otherwise you can't see any fields of nested object on the form. For many nested object it can be
annoying.

## Contributing

1. Fork it ( https://github.com/Loriowar/relation_builder/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
