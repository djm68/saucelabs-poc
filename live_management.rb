#!/usr/bin/env ruby

require 'yaml'
require 'rubygems'
require 'selenium-webdriver'

exit 1 unless sauce_url = ENV['SAUCE_URL']
passwd = ENV['PASSWD'] || passwd = '~!@#$%^*-/aZ'
domain = ENV['DOMAIN'] || domain = ''
config = ENV['CONFIG']
dashboard=''
fail_flag=0
hInfo = YAML.load_file "config/#{config}"

hInfo['HOSTS'].each_pair { |host,val|
  puts "Host: #{host}"
  puts val.inspect
  if hInfo['HOSTS']["#{host}"]['roles'].include? "dashboard"
    puts "#{host} is a Dashboard" 
    dashboard = host
  end
}

caps = Selenium::WebDriver::Remote::Capabilities.send ENV['BROWSER']
caps.version =  ENV['VERSION']
caps.platform = ENV['PLATFORM'].to_sym
caps[:name] = "#{config} Console Login Test"

driver = Selenium::WebDriver.for(
  :remote,
  :url => sauce_url,
  :desired_capabilities => caps)
driver.navigate.to "https://#{dashboard}#{domain}"

# Login
element = driver.find_element(:name, 'username')
element.send_keys "admin@example.com"
element.submit
element = driver.find_element(:name, 'password')
element.send_keys "#{passwd}"
element.submit
if driver.title == "Puppet Node Manager"
  puts "Testcase 1 passed"
 else
  puts "Testcase 1 failed"
  fail_flag=1
end
puts driver.title


element = driver.find_element(:link, 'Live Management')
element.click
wait = Selenium::WebDriver::Wait.new(:timeout => 60) # seconds
wait.until { driver.find_element(:link => "Select all") }

element = driver.find_element(:id, 'selected-node-count')
element.text

if driver.title == "Live Management"
  puts "Testcase 2 passed"
 else
  puts "Testcase 2 failed"
  fail_flag=1
end

puts driver.title
driver.quit

exit fail_flag
