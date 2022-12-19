UNDER CONSTRUCTIONS

# appending

Information-Appending-Service (or just **Appending**) is a Ruby gem for data enrichment of people and companies. 

**Example:** Find a person from its **first name**, **last name** and **company name**.

```ruby
p BlackStack::Appending.find_person('Elon', 'Musk', 'SpaceX')
# => {:matches=>[["ix.persona.us.06", "spacex|elon|musk", "45227", "elon", "musk", "linkedin.com/in/elon-musk-007a911a6", ...
```

You can also try with the full name, and let Appending to guess the first name and last name.

```ruby
p BlackStack::Appending.find_person_with_full_name('Elon Musk', 'SpaceX')
# => {:matches=>[["ix.persona.us.06", "spacex|elon|musk", "45227", "elon", "musk", "linkedin.com/in/elon-musk-007a911a6", ...
```

**Example:** Find people beloning a company from the **company's name**.

```ruby
p BlackStack::Appending.find_company('SpaceX')
# => {:matches=>[["ix.persona.us.01", "spacex|alexander|volkov", "57874", "alexander", "volkov", "linkedin.com/i...
```

**Example:** Get a field of a found record.

```ruby
h = BlackStack::Appending.find_person('Jeff', 'Bezos', 'Amazon')[:matches].first
p BlackStack::Appending.value(h, :email)
# => "bezosj@amazon.com"
```

**Example:** Get the email of all the persons found with same first name, last name and company name.

```ruby
p BlackStack::Appending.find_person('Jeff', 'Bezos', 'Amazon')[:matches].map { |h| BlackStack::Appending.value(h, :email) }
# => ["bezosj@amazon.com", "jbezos@amazon.com", "yangb@amazon.com", "jeffbezos@amazon.com", "resolution@amazon.com", "jeffreybezos@amazon.com", "jeffery.bezos@amazon.com", "jeffreybe@amazon.com", "jeffery@amazon.com"]
```

## 1. Installation

```bash
gem install appending
```

## 2. Configuration

### Defining Indexes

Define the indexes you have to find people by **first name**, **last name** and **company name**.

### Running Indexation

```ruby
BlackStack::CSVIndexer.indexes.each { |i|
    i.index(true)
}
```

## 3. Logging

You can create a logger and add it to the Appending module, to be used internally by all its methods.

```ruby
l = BlackStack::LocalLogger.new('./example1.log')
l.log "Starting example1.rb!"
BlackStack::Appending.set_logger(l)
```

## Notes

- The **Appending** gem works over **[CSV-Indexer](https://github.com/leandrosardi/csv-indexer)**.

