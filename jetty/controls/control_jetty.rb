# encoding: utf-8
#
# Copyright 2017, sarath kumar
#
# dual licensed under the Apache License 2.0 and Eclipse Public License 1.0;
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#     http://www.eclipse.org/licenses/

# author: Sarath kumar

# determine all required paths
jetty_path      = '/opt/jetty'
jetty_conf      = File.join(jetty_path, 'start.ini')
jetty_xml_conf  = File.join(jetty_path,'/etc/jetty.xml')
jetty_script    = File.join(jetty_path, '/bin/jetty.sh')

title 'Jetty server config'

control 'jetty-01' do
  impact 1.0
  title 'checking prerequisite packages installed or not'
  desc  'checking prerequisite packages installed or not'
  describe command('java') do
      #Checking command java responding or not
      it { should exist }
  end
  describe processes('java') do
      #Process java should run
      it { should exist }
  end
  describe service('jetty') do
      #jetty service should be installed,enabled and running
      it { should be_installed}
      it { should be_enabled }
      it { should be_running }
  end
  describe package('openssl')do
      #openssl package should be installed to run jetty server in secured port
      it { should be_installed}
  end
end


control 'jetty-02' do
  impact 1.0
  title 'jetty server should be listening'
  desc  'checking whether jetty server listening to port or not'
  describe port(8080) do
      #jetty server should listen to port 8080
      it { should be_listening }
  end
  describe host('localhost', port: 8080, protocol: 'tcp') do
      # The host should be reachable
      it { should be_reachable }
      it { should be_resolvable }
      its('ipaddress') { should include '127.0.0.1' }
  end
end


control 'jetty-03' do
  impact 1.0
  title 'checking operating system properties'
  desc  'checking operating system properties'
  describe os[:family] do
      it { should eq 'debian' }
  end
  describe os[:arch] do
      it { should eq 'x86_64' }
  end
end

control 'jetty-04' do
  impact 1.0
  title 'checking ssl port enabled or not'
  desc  'checking ssl port enabled or not'
  describe ssl(port: 8443) do
      #port 8443 should be enabled to run jetty server
      it { should be_enabled }
  end
end

control 'jetty-05' do
  impact 1.0
  title 'checking users and groups existence'
  desc  'checking whether user "jetty" and group "jetty" is  existing or not'
  describe user ('jetty') do
      #user jetty should exist
      it   {should exist}
      #user group jetty should exist
      its('groups') { should eq ["jetty"]}
  end
end

control 'jetty-06' do
  impact 1.0
  title 'checking jetty '
  desc  'checking existence of the service file and checking whether service file is linked to systemctl or not to enable the service '
  describe file('/etc/init.d/jetty') do
      it { should exist }
      it { should be_file }
      #service file should be linked to systemctl enable the service.
      it { should be_linked_to '/bin/systemctl' }
  end
  describe file(jetty_script) do
      #jetty script file should exist and it should be executable
      it { should exist }
      it { should be_file }
  end
  describe file(jetty_xml_conf)do
     #jetty script file should exist and it should be executable
     it { should exist }
     it { should be_file}
  end

end

control 'jetty-07'do
  impact 1.0
  title 'checking user permissions'
  desc 'The jetty folder should owned and grouped by jetty, be writable, readable and executable by jetty. It should be readable, executable by group and not readable, not writeable by root.'
  describe directory(jetty_path) do
      # verifies specific users
      it { should be_owned_by 'jetty' }
      it { should be_grouped_into 'jetty' }
      #jetty path should not be writable by others
      it { should be_readable.by('others') }
      it { should_not be_writable.by('others') }
      it { should be_executable.by('others') }
  end
  describe passwd do
     #passwd file should include user "jetty"
     its('users'){ should include 'jetty'}
     #passwd file should not contain forbidden_user
     its('users'){ should_not include 'forbidden_user' }
  end
end

control 'jetty-08'do
  impact 1.0
  title 'security and performance checking'
  desc  'checking minimum and maximum thread size '
  describe ini( jetty_conf )do
    #default minimum thread size is "10" it can be replaced by "8" to make jetty run in optimised way
    its(['jetty.threadPool.minThreads']) { should eq '8' }
    #default maximum thread size is "200" it can be replaced by "100" to make jetty run in optimised way
    its(['jetty.threadPool.maxThreads']) { should eq '100' }
  end
end

control 'jetty-09'do
  impact 1.0
  title 'checking security scheme and security port'
  desc  'checking security scheme should be https and security port should be 8443'
  describe ini( jetty_conf )do
    #security scheme of jetty server should be "https"
    its(['jetty.httpConfig.secureScheme']) { should eq 'https' }
    #secure port of jetty server should be "8443"
    its(['jetty.httpConfig.securePort']) { should eq '8443' }
  end
end

control 'jetty-10'do
  impact 1.0
  title 'cheking host address and port configuration'
  desc  'jetty host address is assgined to 0.0.0.0 and port is 8080'
  describe ini( jetty_conf )do
    #host is the network interface this connector binds to as an IP address or a hostname. If null or 0.0.0.0, bind to all interfaces.
    its(['jetty.http.host']) { should eq '0.0.0.0' }
    #default port nubmer of jetty server is 8080
    its(['jetty.http.port']) { should eq '8080' }
  end
end

control 'jetty-11'do
  impact 1.0
  title 'cheking moniterdPath to deploy'
  desc  'inorder to deploy the webapplications all necessary file should be stored in mointered path '
  describe ini( jetty_conf )do
    #The directory to scan for possible deployable Web Applications (or Deployment Descriptor XML files).
    its(['jetty.deploy.monitoredPath']) {should eq '/var/www/webapps'}
  end
end

control 'jetty-12'do
  impact 1.0
  title 'cheking soLingerTime,compilance and scan intraval'
  desc  'cheking soLingerTime,compilance and scan intraval'
  describe ini( jetty_conf )do
    #A value greater than zero sets the socket SO_LINGER value in milliseconds. Jetty attempts to gently close all TCP/IP connections with proper half close semantics, so a linger timeout should not be required and thus the default is -1.
    its(['jetty.http.soLingerTime']) { should eq '-1' }
    #the defualt compilance scheme is RFC7230 it is changed to RFC2616 to make jetty secue
    its(['jetty.http.compliance']) { should eq 'RFC2616' }
    #Number of seconds between scans of the provided monitoredDirName. A value of 0 disables the continuous hot deployment scan, Web Applications will be deployed on startup only.
    its(['jetty.deploy.scanInterval']) { should eq '1' }
  end
end

control 'jetty-13'do
  impact 1.0
  title 'safety shutdown feature and time taken to stop the server'
  desc  'safety shutdown should be enabled and time taken to stop the server should be less than or equal to 3 seconds'
  describe ini( jetty_conf )do
    #jetty server can be safely shutdown by pressing ctrl+c to make this enable stopAtShutdown should be true
    its(['jetty.server.stopAtShutdown']) { should eq 'true' }
    #Default stopTimeout of jetty is 5000 (5 seconds) its too long so stopTimeout can be changed to 3000 (3 seconds)
    its(['jetty.server.stopTimeout']) { should eq '3000' }
  end
end

control 'jetty-14'do
  impact 1.0
  title 'checking error dispatch and blocking time out'
  desc  'Error dispatch is use to prevent looping .block time out is the time take to block a IO operation'
  describe ini( jetty_conf )do
    #to prevent looping maximum error dispatch is changed to 5 to increse the performance
    its(['jetty.httpConfig.maxErrorDispatches']) { should eq '5' }
    #Maximum time to block in total for a blocking IO operation
    its(['jetty.httpConfig.blockingTimeout']) { should eq '-1' }
  end
end
