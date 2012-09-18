# FuzzBert [![Build Status](https://secure.travis-ci.org/krypt/FuzzBert.png?branch=master)](http://travis-ci.org/krypt/FuzzBert)

A random testing/fuzzer framework for Ruby.

Random Testing (or "fuzzing") is not really new, it has been around for quite
some time. Yet it still hasn't found widespread adoption in everyday coding
practices, much too often it is only used for the purpose of finding exploits
for existing applications or libraries. FuzzBert wants to improve this situation.
It's a simple fuzzing framework with an RSpec-like DSL that will allow you to 
integrate random tests in your project with minimal effort.

For further information on random testing, here are two excellent starting points:

* [Udacity CS258](http://www.udacity.com/overview/Course/cs258/)
* [Babysitting an Army of Monkeys](http://fuzzinginfo.files.wordpress.com/2012/05/cmiller-csw-2010.pdf)

## Installation

    gem install fuzzbert
    fuzzbert --help

## Defining a random test

FuzzBert defines an RSpec-like DSL that can be used to define different fuzzing
scenarios. The DSL uses three words: `fuzz`, `deploy` and `data`. 

Here is a quick example that fuzzes `JSON.parse`:

```ruby
require 'json'
require 'fuzzbert'

fuzz "JSON.parse" do

  deploy do |data|
    begin
      JSON.parse data
    rescue StandardError
      #fine, we just want to capture crashes
    end
  end

  data "completely random" do
    FuzzBert::Generators.random
  end

  data "enclosing curly braces" do
    c = FuzzBert::Container.new
    c << FuzzBert::Generators.fixed("{")
    c << FuzzBert::Generators.random
    c << FuzzBert::Generators.fixed("}")
    c.generator
  end

  data "my custom generator" do
    prng = Random.new
    lambda do
      buf = '{ user: { '
      buf << prng.bytes(100)
      buf << ' } }'
    end
  end

end
```

`fuzz` can be thought of as defining a new scenario, such as "fuzz this command 
line tool", "fuzz this particular URL of my web app" or "fuzz this library method 
taking external input".

Within a `fuzz` block, there must be one occurence of `deploy` and one or several
occurences of `data`. The `deploy` block is the spot where we deliver the random
payload that has been generated. It is agnostic about the actual target in order to
leave you free to fuzz whatever you require in your particular case. The `data`
blocks define the shape of the random data being generated. There can be more than
one such block because it is often beneficial to not only shoot completely random
data at the target - you often want to deliver more structured data as well, trying
to find the edge cases deeper within your code. Good random test suites make use
of both - totally random data as well as structured data - in order to cover as
much "code surface" as possible.

The `deploy` block takes the generated data as a parameter. The block itself is
responsible of deploying the payload. An execution is considered successful if
the `deploy` block passes with no uncaught error being raised. If an error slips
through or if the Ruby process crashes altogether, the execution is of course
considered as a failure. 

`data` blocks must return a lambda or proc that takes no argument. You can either
choose completely custom lambdas of your own or use those predefined for you in
`FuzzBert::Generators`.

## Running a random test

Once the FuzzBert files are set up, you may run your tests similar to how you
would run unit tests:

    fuzzbert "fuzz/**/fuzz_*.rb"

If your FuzzBert files are already in a directory named 'fuzz' and each of them
begins with 'fuzz_', you may omit the pattern altogether. 

Each `fuzz` block defines a `TestSuite`. These are executed in a round-robin manner.
Each individual `TestSuite` will then apply the `deploy` block with a sample of
data generated successively by each one of the `data` blocks. Once all `data` blocks
are used up, the next `TestSuite` will be executed etc. By default, a FuzzBert
fuzzing session runs forever, until the process is either killed or by manually hitting
`CTRL+C` for example. This was a deliberate design choice since random testing suites
need to be run for quite some time to be effective. It's something you want to run over
the weekend rather than for a couple of minutes. Still, it can make sense to explicitly
limit the number of runs, for example when integrating FuzzBert with a CI server or
with Travis. You can do so by passing the `--limit` parameter to the `fuzzbert`
executable:

    fuzzbert --limit 1000000 "fuzz/**/fuzz_*.rb"

Every single execution of `deploy` is run in a separate process. The main reason for
this is that we typically want to detect hard crashes when a C extension or even Ruby
itself encounters an input it can't handle. Besides being able to cope with these cases,
running in separate processes proves beneficial otherwise as well: by default, FuzzBert
runs the tests in four separate processes at once, therefore utilizing your CPU's cores
effectively. You can tweak that setting with `--pool-size` to set this number to 1 
(for completely sequential runs) or to the exact number of cores your CPU offers.

    fuzzbert --pool-size 1 my/fuzzbert/file

## What happens if we encounter a bug?

If a test should end up failing (either the process crashed completely or caused an
uncaught error), FuzzBert will output the failing test on your terminal and tell you
where it stored the data that caused this. This conveniently allows you to run FuzzBert
over the weekend and when you return on Monday, the troubleshooters will sit there all
lined up for you to go through and filter. By using the `--console` command line switch
you can tell FuzzBert to not explicitly store the data, but echoing the data that
caused the crash to the terminal instead.

    fuzzbert --console "fuzz/**/fuzz_*.rb"

If you don't want to litter your current working directory with the files generated
by FuzzBert, you can also specify a specific path to where they should be saved
instead:

    fuzzbert --bug-dir bugs "fuzz/**/fuzz_*.rb"

This is still not quite what you want to happen in case a test crashes? There's
also the possibility to define a handler of your own:

```ruby
require 'fuzzbert'

class MyHandler
  def handle(error_data)
    #create an issue in the bug tracker
    puts error_data[:id]
    p error_data[:data]
    puts error_data[:pid]
    puts error_data[:status]
  end
end

fuzz "Define here as usual" do
  ...
end
```

Now you just need to tell FuzzBert to use your custom handler:

    fuzzbert --handler MyHandler my/fuzzbert/file

## Templates

Using the approach described so far is most useful for binary protocols, but as
soon as you work with mainly String-based data this can quickly become a chore. 
What you actually want in these situations is some sort of template mechanism 
that comes with mostly fixed data and only replaces a few selected parts with
randomly generated data. This, too, is possible with FuzzBert, it comes with a 
minimal templating language:

```ruby
require 'fuzzbert'

fuzz "My Web App" do

  deploy do |data|
    # Send the data to your web app with httpclient or similar.
    # You define the "error conditions": if a response to some
    # data is not as expected, you could simply raise an error
    # here.
  end

  data "JSON generated from a template" do
    t = FuzzBert::Template.new '{ user: { id: ${id}, name: "${name}" } }'
    t.set(:id) { FuzzBert::Generators.cycle(1..10000) }
    t.set(:name) { FuzzBert::Generators.random }
    t.generator
  end

end
```

Simply specify your template variables using `${..}` and assign a callback for
them via `set`. Of course you may escape the dollar sign with a backslash as
usual.

## Mutators

Mutation is the principle used in "Babysitting an Army of Monkeys". The basis for
the mutation tests is a valid sample of input that is then modified in exactly one
position in each test instance. You can apply this principle as follows:

```ruby
require 'fuzzbert'

fuzz "Web App" do
  deploy do |data|
    #send JSON data via HTTP
  end

  data "mutated data" do
    m = FuzzBert::Mutator.new '{ user: { id: 42, name: "FuzzBert" }'
    m.generator
  end

end
```

This will take the original JSON data and modify one byte each time data is being
generated.

## Rake integration

You may integrate Rake tasks for FuzzBert similar to how you would include a task for
Rspec:

```ruby
require 'rake'
require 'fuzzbert/rake_task'

FuzzBert::RakeTask.new(:fuzz) do |spec|
  spec.fuzzbert_opts = ['--limit 10000000', '--console']
  spec.pattern = 'fuzz/**/fuzz_*.rb'
end
```

## Supported versions

FuzzBert has been confirmed to run on CRuby 1.9.3 and Rubinius 2.0.0dev. Since
it heavily relies on forking, it does not run on JRuby so far, but support is planned and
on its way.

You may also use FuzzBert for fuzzing arbitrary applications or libraries that aren't
connected to Ruby at all - have a look in the examples that ship with FuzzBert.
 
## License

Copyright (c) 2012 Martin Boßlet. Distributed under the MIT License. See LICENSE for 
further details.

