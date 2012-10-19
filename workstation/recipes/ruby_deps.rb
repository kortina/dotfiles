# using gem_package to install these was doing the install as root or something strange
[
    "cheat",
    "debugger",
    "rack",
    "ruby-debug19",
    "thor",
    "stubb",
    "vagrant"
].each do |pkg|
    execute "gem install #{pkg}" do
        command "gem install #{pkg}"
        user WS_USER
        action :run
        not_if "gem list | grep \"^#{pkg} \""
    end
end

execute "make sure rvm creates vagrant executable in bin" do
    user WS_USER
    command "source $HOME/.rvm/scripts/rvm && rvm use ruby-1.9.3-p194"
    action :run
    not_if "which vagrant"
end
