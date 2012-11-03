dotfiles_path = File.expand_path(File.dirname(__FILE__)+"../../..") # a few levels up from this file

if File.directory?("#{dotfiles_path}/../venmo-workstation")
    include_recipe "venmo-workstation::all"
else
    puts "WARNING: looks like this is not a venmo-workstation. No venmo-workstation directory at same level as this dotfiles repo."
end
