tarball = "ctags-5.8.tar.gz"
local_path = "/tmp/#{tarball}"
remote_url = "https://dl.dropbox.com/s/c8lnlskupvdc9gi/#{tarball}?dl=1"
remote_file local_path do
    user WS_USER
    source remote_url
    not_if "test -e #{local_path}"
end

execute "install ctags" do
    action :run
    cwd "/tmp"
    command "tar -zxvf #{tarball} && cd ctags-5.8 && ./configure && make && make install"
    not_if "which ctags | grep -q local" # if we're already using /opt/local or /usr/local version, OK
end


execute "install ctags with obj c" do
    action :run
    cwd "/tmp"
    command "(test -e /tmp/ctags-ObjC-5.8.1 || git clone https://github.com/mcormier/ctags-ObjC-5.8.1) && cd ctags-ObjC-5.8.1 && ./configure && make && mv ctags /usr/local/bin/ctags-objc"
    not_if "which ctags-objc | grep -q local" # if we're already using /opt/local or /usr/local version, OK
end
