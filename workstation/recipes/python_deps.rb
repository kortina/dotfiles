# pyflakes
execute "checkout pyflakes to tmp" do
    user WS_USER
    cwd "/tmp"
    command "git clone git://github.com/kevinw/pyflakes.git"
    not_if "test -e /tmp/pyflakes || python -c 'import pyflakes'"
end
execute "install pyflakes" do
    user "root"
    cwd "/tmp/pyflakes"
    command "python setup.py install"
    not_if "python -c 'import pyflakes'"
end

