#!/bin/env ruby
# encoding: utf-8

done_message = <<EOF

Done running chef.

### Jenkins

To run jenkins, do:
java -jar /usr/local/Cellar/jenkins/1.477/libexec/jenkins.war

Jenkins will be available at:
http://localhost:8080/

(If jenkins is not there, sudo locate jenkins)

EOF

execute "success banner" do
    command "echo -e \"\033[32m✭ Successful chef run ✭\033[0m\""
    only_if {puts done_message; 1}
end
