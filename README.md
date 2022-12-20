UNDER CONSTRUCTIONS

# appending

Information-Appending-Service (or just **Appending**) is a Ruby gem for data enrichment of people and companies. 

**Example:** Find a person from its **first name**, **last name** and **company name**.

```ruby
# Getting looking for possible emails of Elon Musk 
p BlackStack::Appending.find_persons('Elon', 'Musk', 'SpaceX').map { |res| 
    res.emails 
}.flatten.uniq.reject { |email|
    email.empty?
}
# => ["emusk@spacex.com", "elon@spacex.com", "elon.musk@spacex.com", "elonmusk@spacex.com", "musk@spacex.com"]
```

## 1. Installation

```bash
gem install appending
```

## 2. Getting Started

Appending requires you have a huge database of people in CSV format, with your columns you want to append.

Setting up Appending requires you understand our other [CSV Indexer](https://github.com/leandrosardi/csv-indexer).

### 2.1. Defining Indexes

Define the indexes you have to find people by **first name**, **last name** and **company name**.

Refer to [CSV Indexer](https://github.com/leandrosardi/csv-indexer) to learn how to define indexes.

### 2.2. Running Indexation

Building the indexes is very simple.

```ruby
BlackStack::CSVIndexer.indexes.each { |i|
    i.index(true)
}
```

Refer to [CSV Indexer](https://github.com/leandrosardi/csv-indexer) to learn how to build indexes.

### 2.3. Setting Up

```ruby
BlackStack::Appending.set({
    # what are the indexes you will use for this appending?
    :indexes => BlackStack::CSVIndexer.indexes.select { |i| i.name =~ /persona/ },
    
    # for email verification
    :verifier_url => 'https://connectionsphere.com/api1.0/emails/verify.json',
    :verifier_api_key => '<write your ConnectionSphere API-Key here>',

    # funding specific data
    :email_fields => [:email, :email1, :email2],
    :phone_fields => [:phone, :phone1, :phone2],
    :company_domain_fields => [:company_domain],
})
```

## 3. Logging

You can create a logger and add it to the Appending module, to be used internally by all its methods.

```ruby
l = BlackStack::LocalLogger.new('./example1.log')
l.log "Starting example1.rb!"
BlackStack::Appending.set_logger(l)
```

## 4. Examples

### 4.1. Looking for possible emails of Elon Musk 

Find persons by first name, last name and company where they are working.

```ruby
l.log "Example: Looking for a lead."
p BlackStack::Appending.find_persons('Elon', 'Musk', 'SpaceX').map { |res| 
    res.emails 
}.flatten.uniq.reject { |email|
    email.empty?
}
# => ["emusk@spacex.com", "elon@spacex.com", "elon.musk@spacex.com", "elonmusk@spacex.com", "musk@spacex.com"]
```

### 4.2. Looking for people by its full name

Provide the full name of the lead in one single string, and let Appending to guess what are the first name and last name.

```ruby
p BlackStack::Appending.find_persons_with_full_name('Elon Musk', 'SpaceX').map { |res| 
    res.emails 
}.flatten.uniq.reject { |email|
    email.empty?
}
# => ["emusk@spacex.com", "elon@spacex.com", "elon.musk@spacex.com", "elonmusk@spacex.com", "musk@spacex.com"]
```

### 4.3. Getting a VERIFIED email addresses

```ruby
p BlackStack::Appending.find_verified_emails('Jackson', 'Wise', 'Comma Insurance')
# => ["jackson.wise@commainsurance.com"]
```

### 4.4. Looking the phone numbers of someone

```ruby
p BlackStack::Appending.find_persons('Jackson', 'Wise', 'Comma Insurance').map { |res| 
    res.phones
}.flatten.uniq.reject { |phone|
    phone.empty?
}
# => "555-5555"
```

## Notes

- The **Appending** gem works over **[CSV-Indexer](https://github.com/leandrosardi/csv-indexer)**.

