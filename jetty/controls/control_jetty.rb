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
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# author: Sarath kumar

title 'Jetty server config'
control 'jetty-01' do
  impact 1.0
  title 'checking java installed or not'
  desc  'checking java installed or not'
  describe command('java') do
      it { should exist }
  end
  describe processes('java') do
      it { should exist }
  end
  describe service('jetty') do
      it { should be_installed }
      it { should be_enabled }
      it { should be_running }
  end
  describe package('openssl')do
      it { should be_installed}
  end
end


control 'jetty-02' do
  impact 1.0
  title 'jetty server should be listening'
  desc  'jetty server should be listening'
  describe port(8080) do
      it { should be_listening }
  end
  describe host('localhost', port: 8080, protocol: 'tcp') do
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
  title 'checking user access'
  desc  'checking user access'
  describe user('root') do
      it { should exist }
      its('groups') { should eq ["root"]}
  end
  describe user ('jetty') do
      it   {should exist}
      its('groups') { should eq ["jetty"]}
  end
end

control 'jetty-05' do
  impact 1.0
  title 'checking jetty configuration'
  desc  'checking jetty configuration'
  describe file('/etc/init.d/jetty') do
      it { should exist }
      it { should be_file }
      it { should be_linked_to '/bin/systemctl' }
  end
  describe file('/opt/jetty/bin/jetty.sh') do
      it { should exist }
      it { should be_file }
  end

end

control 'jetty-06'do
  impact 1.0
  title 'checking user permissions'
  desc 'The jetty folder should owned and grouped by jetty, be writable, readable and executable by jetty. It should be readable, executable by group and not readable, not writeable by root.'
  describe directory('/opt/jetty') do
      # verifies specific users
      it { should be_owned_by 'jetty' }
      it { should be_grouped_into 'jetty' }
      it { should be_readable.by('others') }
      it { should_not be_writable.by('others') }
      it { should be_executable.by('others') }
  end
  describe passwd do
     its('users'){ should include 'jetty'}
     its('users'){ should_not include 'forbidden_user' }
  end
end

control 'jetty-07'do
  impact 1.0
  title 'security and performance checking'
  desc 'checking security and performance of jetty server'
  describe ini('/opt/jetty/start.ini')do
    its(['jetty.threadPool.minThreads']) { should eq '8' }
    its(['jetty.threadPool.maxThreads']) { should eq '200' }
    its(['jetty.threadPool.idleTimeout']) { should eq '60000' }
    its(['jetty.httpConfig.secureScheme']) { should eq 'https' }
    its(['jetty.httpConfig.securePort']) { should eq '8443' }
    its(['jetty.httpConfig.outputBufferSize']) { should eq '32768' }
    its(['jetty.httpConfig.outputAggregationSize']) { should eq '8192' }
    its(['jetty.httpConfig.requestHeaderSize']) { should eq '8192' }
    its(['jetty.httpConfig.responseHeaderSize']) { should eq '8192' }
    its(['jetty.httpConfig.sendServerVersion']) { should eq 'true' }
    its(['jetty.httpConfig.sendDateHeader']) { should eq 'false' }
    its(['jetty.httpConfig.headerCacheSize']) { should eq '512' }
    its(['jetty.httpConfig.delayDispatchUntilContent']) { should eq 'true' }
    its(['jetty.httpConfig.maxErrorDispatches']) { should eq '7' }
    its(['jetty.httpConfig.blockingTimeout']) { should eq '1' }
    its(['jetty.server.stopAtShutdown']) { should eq 'true' }
    its(['jetty.server.stopTimeout']) { should eq '3000' }
    its(['jetty.http.host']) { should eq '0.0.0.0' }
    its(['jetty.http.port']) { should eq '8080' }
    its(['jetty.http.idleTimeout']) { should eq '3000' }
    its(['jetty.http.soLingerTime']) { should eq '-1' }
    its(['jetty.http.acceptors']) { should eq '-1' }
    its(['jetty.http.selectors']) { should eq '-1' }
    its(['jetty.http.acceptorQueueSize']) { should eq '0' }
    its(['jetty.http.acceptorPriorityDelta']) { should eq '0' }
    its(['jetty.http.compliance']) { should eq 'RFC2616' }
    its(['jetty.deploy.scanInterval']) { should eq '1' }
    its(['jetty.deploy.monitoredPath']) {should eq '/var/www/webapps'}
  end
end
