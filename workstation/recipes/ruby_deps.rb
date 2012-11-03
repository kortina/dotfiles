# using gem_package to install these was doing the install as root or something strange
[
    "cheat",
    "debugger",
    "rack",
    "ruby-debug19",
    "thor",
    "soloist",
    "stubb",
    "vagrant"
].each do |pkg|
    execute "#{WS_HOME}/.rvm/bin/gem install #{pkg}" do
        command "#{WS_HOME}/.rvm/bin/gem install #{pkg}"
        user WS_USER
        action :run
        not_if "gem list | grep \"^#{pkg} \""
    end
end

execute "make sure rvm creates vagrant executable in bin" do
    user WS_USER
    command "#{WS_HOME}/.rvm/bin/rvm use ruby-1.9.3-p194"
    action :run
    not_if "which vagrant"
end
