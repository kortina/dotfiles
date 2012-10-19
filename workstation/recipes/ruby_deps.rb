# using gem_package to install these was doing the install as root or something strange
[
    "cheat",
    "debugger",
    "rack",
    "ruby-debug19",
    "thor",
    "stubb"
].each do |pkg|
    execute "gem install #{pkg}" do
        command "gem install #{pkg}"
        user WS_USER
        action :run
        not_if "gem list | grep \"^#{pkg} \""
    end
end
