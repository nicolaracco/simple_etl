simple_etl
==========

An easy-to-use toolkit to help you with ETL (Extract Transform Load) operations.

Simple ETL 'would be' (:D) framework-agnostic and easy to use.


## TODO

1) Make this readme readable by humans

## Source

Source namespace is responsible of input files parsing.

First of all you have to define a "source template":

```ruby
    define :format_name do
      [...]
    end
```

In a real use case you will replace :format_name with the format plugin you will use.

Insert the template definition in a file (for example: ./etc/my_template.stl). To load the definition use the following code:

```ruby
    my_template = SimpleEtl::Source.load './etl/my_template.stl'
```

_my_template_ will have the following methods:
- *parse_file* will parse a file
- *parse_rows* will parse an array
- *parse_row* will parse a single source row

All the methods described above will return a ParseResult object. A row is a model that will contain all the attributes specified in the source template as accessors.

### Structure of the template definition

A template definition is composed by three layers:
- raw fields
- transformations
- generators

Generally the raw fields are defined as specified in the following snippet:

```ruby
    field           :name  # generic field
    integer         :age # integer field. Will raise error if the field is not an integer
    required_string :surname # string field. Will raise error if field is nil or empty.
```

but every format plugin will define its own syntax to define the raw fields: for example the fixed width plugin will require :start and :length attributes, as in the following example:

```ruby
  define :fixed_width
    field           :name, :start => 10, :length => 2
    integer         :age,     12, 2
    required_string :surname, 14, 5
  end
```

Transformations and generators: the following code should exaplain you everything

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

### Validation

When parsing a row, the parser will apply a transformation only if the field is valid (otherwise an error will be logged).
After a row is parsed, the parser will execute the generators only if the entire row is valid.

When your parse procedure is completed, always remember to check if the parse was successful:

```ruby
    result = my_template.parse_file './datafiles/file.dat'
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