# Scb Easy API SDK for Ruby

[![Gem Downloads](https://img.shields.io/gem/dt/scb_easy_api.svg)](https://rubygems.org/gems/scb_easy_api)
[![Gem-version](https://img.shields.io/gem/v/scb_easy_api.svg)](https://rubygems.org/gems/scb_easy_api)

## Introduction

The Scb Easy API SDK for Ruby makes it easy to develop using Scb Easy API

## Documentation

See the official API documentation for more information

- English: https://developer.scb/#/documents/documentation/basics/getting-started.html

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'scb_easy_api'
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install scb_easy_api
```

## Synopsis

Usage:

```ruby
# example.rb

class Example
  def client
    @client ||= ScbEasyApi::Client.new do |config|
      config.api_key = ENV["scb_api_key"]
      config.api_secret = ENV["scb_api_secret"]
      config.biller_id = ENV["scb_biller_id"]
      config.merchant_id = ENV["scb_merchant_id"]
      config.terminal_id = ENV["scb_terminal_id"]
      config.reference_prefix = ENV["scb_reference_prefix"]
    end
  end

  def create_paymemnt
    client.create_paymemnt(2_000)
  end

  def create_qrcode_paymemnt
    client.create_qrcode_paymemnt(2_000)
  end
end
```
