#!/usr/bin/env ruby

require 'rubygems'
require 'selenium-webdriver'

#caps = Selenium::WebDriver::Remote::Capabilities.ie
caps = Selenium::WebDriver::Remote::Capabilities.send ENV['BROWSER']
sauce_url = ENV['SAUCE_URL']
caps.version = ENV['VERSION']
caps.platform = ENV['PLATFORM'].to_sym
caps[:name] = "Console Login Test"

driver = Selenium::WebDriver.for(
  :remote,
  :url => sauce_url,
  :desired_capabilities => caps)
driver.navigate.to "https://ec2-107-21-161-183.compute-1.amazonaws.com"

# Login
element = driver.find_element(:name, 'username')
element.send_keys "admin@example.com"
element.submit
element = driver.find_element(:name, 'password')
element.send_keys "puppet"
element.submit

if driver.title == "Puppet Node Manager"
  puts "Testcase 1 passed"
else
  puts "Testcase 1 failed"
end

puts driver.title
driver.quit
