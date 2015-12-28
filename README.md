# EXEL
[![Gem Version](https://badge.fury.io/rb/exel.svg)](https://badge.fury.io/rb/exel)
[![Code Climate](https://codeclimate.com/github/47colborne/exel/badges/gpa.svg)](https://codeclimate.com/github/47colborne/exel)
[![Build Status](https://snap-ci.com/47colborne/exel/branch/master/build_image)](https://snap-ci.com/47colborne/exel/branch/master)

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

TODO: add more detail

### The Context

TODO

### Supported Commands

* ```process``` Execute the given processor class (specified by the ```:with``` option), given the current context and any additional arguments provided

* ```split``` Split the input data into 1000 line chunks and run the given block for each chunk. Assumes that the input data is a CSV formatted file referenced by ```context[:resoource]```. When each block is run, ```context[:resource]``` will reference to the chunk file.
* ```async``` Asynchronously run the given block. Uses the configured async provider to execute the block.

### Example job

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

Elsewhere in your application, you could run the job like so:

    def run_example_job(file_path)
        context = EXEL::Context.new(file_path: file_path, user: 'username')
        EXEL::Job.run(:example_job, context)
    end

## Contributing

1. Fork it ( https://github.com/[my-github-username]/exel/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
