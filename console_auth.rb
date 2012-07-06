#!/usr/bin/env ruby

require 'yaml'
require 'rubygems'
require 'selenium-webdriver'

exit 1 unless ENV['SAUCE_URL']
config = ENV['CONFIG']
dashboard=''
fail_flag=0
#hInfo = YAML.load_file './ubuntu1004-64mda.cfg'
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
sauce_url =     ENV['SAUCE_URL']
caps.version =  ENV['VERSION']
caps.platform = ENV['PLATFORM'].to_sym
caps[:name] = "Console Login Test"

driver = Selenium::WebDriver.for(
  :remote,
  :url => sauce_url,
  :desired_capabilities => caps)
driver.navigate.to "https://#{dashboard}"

# Login
element = driver.find_element(:name, 'username')
element.send_keys "admin@example.com"
element.submit
element = driver.find_element(:name, 'password')
element.send_keys "puppet"
#element.send_keys '~!@#$%^*-/aZ'
element.submit

if driver.title == "Puppet Node Manager"
  puts "Testcase 1 passed"
 else
  puts "Testcase 1 failed"
  fail_flag=1
end

puts driver.title
driver.quit

return fail_flag
