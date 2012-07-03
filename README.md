simple_etl
==========

An easy-to-use toolkit to help you with ETL (Extract Transform Load) operations.

Simple ETL 'would be' (:D) framework-agnostic and easy to use.


## Source

Source namespace is responsible of input files parsing.

First of all you have to define a "source template" inside a definition file (for example _my_template.stl_):

```ruby
    define :format_name do
      field :name
      field :surname
    end
```

Then you will load the template with the following code:

```ruby
    my_template = SimpleEtl::Source.load './etl/my_template.stl'
```

At this point you can parse a source and process the result as with the following code:

```ruby
    my_template.parse '....', :type => :inline # load data inline
    result = my_template.parse 'source.dat' # load from file

    if result.valid?
      result.rows.each do |row|
        puts "|\t#{row.name}\t|\t#{row.surname}\t|"
      end
      puts "Parse Completed!"
    else
      result.errors.each do |error|
        puts "Error while parsing line #{error.row_index}: #{error.message}"
      end
    end
```

As you can see the result is valid if there are no errors.

The rows array contains all the parsed rows. Each row contains the parsed attributes as accessors.

The errors array contains all the generated errors. Each error is an object with 'row_index', 'message' and 'exception' properties.

## Structure of the template definition

A template definition is composed by three layers:
- raw fields
- transformations
- generators

### Fields

```ruby
    field :name
    field :surname, :type => :string, :required => true
```

By default type is 'object'. It means it's not converted in any format. Other possible types are:

- *string*: field is stripped by extra spaces;

- *integer*: field is stripped. If the input value is nil or empty, nil is returned; it's converted in integer if the value contains numbers; a CastError is raised otherwise;

- *float*: field is stripped. If the input value is nil or empty, nil is returned; it's converted in float if the value contains numbers; a CastError is raised otherwise;

- *boolean* field is stripped. If the input value is nil or empty, nil is returned; it's converted in boolean if the input value is true,false,1,0; a CastError is raised otherwise;

The template definition will provide you an helper for each defined type. So you can write:

```ruby
    string :name
    integer :age
```

For each helper, an additional 'required' helper will also be available:

```ruby
    required_string :name
    required_integer :age
```

Remember: *every format plugin will define its own field syntax, so remember to read the [Wiki](https://github.com/nicolaracco/simple_etl/wiki)*


### Transformers and generators

They are functions that help you manipulate the parsed raw data:

```ruby
    transform :name { |name| name.downcase } # => name field is transformed in downcase

    # a full_name field will be present in the row
    generate :full_name do |row|
      "#{row.name} #{row.surname}"
    end

    generate :company do |row|
      if cmp = Company.find(row.company_id)
        cmp
      else
        raise ParseError.new "Cannot find a company with id #{row.company_id}"
      end
    end
```

A transformer is a code block that transform a particular value. It's executed as soon as the input value is parsed (if it's valid).

A generator is a code block that generates a new property for the current row.
All the generators are executed when the entire row as been read and transformed.