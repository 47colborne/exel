# EXEL
[![Gem Version](https://badge.fury.io/rb/exel.svg)](https://badge.fury.io/rb/exel)
[![Code Climate](https://codeclimate.com/github/47colborne/exel/badges/gpa.svg)](https://codeclimate.com/github/47colborne/exel)
[![Test Coverage](https://codeclimate.com/github/47colborne/exel/badges/coverage.svg)](https://codeclimate.com/github/47colborne/exel/coverage)
[![Build Status](https://snap-ci.com/47colborne/exel/branch/master/build_image)](https://snap-ci.com/47colborne/exel/branch/master)
[![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](http://www.rubydoc.info/github/47colborne/exel/master)

EXEL is the Elastic eXEcution Language, a simple Ruby DSL for creating processing jobs that can be run on a single machine, or scaled up to run on dozens of machines with no changes to the job itself. To run a job on more than one machine, simply install EXEL async and remote provider gems to integrate with your preferred platforms. The currently implemented providers so far are:

**Async Providers**

* [exel-sidekiq](https://github.com/47colborne/exel-sidekiq)

**Remote Providers**

* [exel-s3](https://github.com/47colborne/exel-s3)

## Installation

Add this line to your application's Gemfile:

    gem 'exel'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install exel

## Usage

### Processors

A processor can be any class that provides the following interface:

```ruby
class MyProcessor
  def initialize(context)
    # typically context is assigned to @context here
  end

  def process(block)
    # do your work here
  end
end
```

Processors are initialized immediately before ```#process``` is called, allowing them to set up any state that they need from the context. The ```#process``` method is where your processing logic will be implemented. Processors should be focused on performing one particular aspect of the processing that you want to accomplish, allowing your job to be composed of a sequence of small processing steps. If a block was given in the call to ```process``` in the job DSL, it will be passed as the argument to ```#process``` and can be run with: ```block.run(@context)```

### The Context

The ```Context``` class has a Hash-like interface and acts as shared storage for the various processors that make up a job. Processors take their expected inputs from the context, and place any resulting outputs there for subsequent processors to access. Values are typically placed in the context through the following means:

* Initial context set up before the job is run
* Arguments passed to processors in the job DSL
* Outputs assigned by processors during processing

If you use EXEL with an async provider, such as [exel-sidekiq](https://github.com/47colborne/exel-sidekiq), and a remote provider, such as [exel-s3](https://github.com/47colborne/exel-s3), a context switch will occur when the ```async``` instruction is executed. Context shifts involve serializing the context and uploading it via the remote provider, then downloading and deserializing it when the async block is eventually run. This allows the processors to pass the results of their process through the sequence of processors in the job, without having to be concerned with when, where, or how those processors will be run.

### Supported Instructions

* ```process``` Executes the given processor class (specified by the ```:with``` option), given the current context and any additional arguments provided
* ```split``` Splits the input data into 1000 line chunks and run the given block for each chunk. Assumes that the input data is a CSV formatted file referenced by ```context[:resource]```. When each block is run, ```context[:resource]``` will reference to the chunk file.
* ```async``` Asynchronously runs the given block. Uses the configured async provider to execute the block.
* ```run``` Runs the job specified by the ```:job``` option. The job will run using the current context.
* ```listen``` Registers an event listener. See the [Events](#events) section below for more detail.

### Example job

```ruby
EXEL::Job.define :example_job do
  # Download a large CSV data file
  process with: FTPDownloader, host: ftp.example.com, path: context[:file_path]

  # split it into smaller 1000 line files
  split do
    # for each file asynchronously run the following sequence of processors
    async do  
      process with: RecordLoader # convert each row of data into your domain model
      process with: SomeProcessor # apply some additional processing to each record
      process with: RecordSaver # write this batch of records to your database
      process with: ExternalServiceProcessor # interact with some service, ex: updating a search index
    end
  end
end
```

Elsewhere in your application, you could run this job as follows:

```ruby
def run_example_job(file_path)
  # context can also be passed as a Hash
  context = EXEL::Context.new(file_path: file_path, user: 'username')
  EXEL::Job.run(:example_job, context)
end
```

### Events

Event listeners can be registered using the ```listen``` instruction:

```ruby
listen for: :my_event, with: MyEventListener
```

The event listener must implement a method with the same name as the event which accepts two arguments: the context and any data passed when the event was triggered:

```ruby
class MyEventListener
  def self.my_event(context, data)
    # handle event
  end
end
```

To trigger an event, include the ```EXEL::Events``` module and call #trigger with the event name and data:

```ruby
include EXEL::Events

def process(_block)
  # trigger event and optionally pass data to the event listener
  trigger :my_event, foo: 'bar'
end
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/exel/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
