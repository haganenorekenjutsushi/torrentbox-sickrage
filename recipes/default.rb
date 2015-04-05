#
# Cookbook Name:: sickrage
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# Ensure the prerequisites are installed
log "Checking SickRage prerequisites for #{node['platform']}"
node['sickrage']['prerequisites']['linux'].each do |prereq|
	log "Processing #{prereq}"
	apt_package prereq do
	  action :install
	end
end

# Ensure we've got a service account
user node['sickrage']['config']['user'] do
  supports :manage_home => true
  gid "users"
  home "/home/#{node['sickrage']['config']['user']}"
  shell "/bin/bash"
  password node['sickrage']['config']['password']
end

# Control the installation dir
directory node['sickrage']['config']['path'] do
  owner node['sickrage']['config']['user']
  group 'user'
  mode '0755'
  action :create
end

# Control the data dir
directory node['sickrage']['config']['datadir'] do
  owner node['sickrage']['config']['user']
  mode '0755'
  action :create
end

# Assume ownership of the contents of the data directory (useful when populating a backup in another recipe)
execute "own-datadir-sickrage" do
  command <<-EOH    
  chown -R #{node['sickrage']['config']['user']} #{node['sickrage']['config']['datadir']}
  EOH
end


log "Fetching latest GIT repo"
git node['sickrage']['config']['path'] do
  user node['sickrage']['config']['user']
	repository node['sickrage']['repo']
	revision node['sickrage']['config']['branch']
	action :sync
end

# Replace piratebay address in provider
ruby_block "replace piratebay address in provider" do
  block do
    file_name = "#{node['sickrage']['config']['path']}/sickbeard/providers/thepiratebay.py"
    text = File.read(file_name)
    new_contents = text.gsub(/#{node['sickrage']['config']['providers_replace']['piratebay']['search']}/, "#{node['sickrage']['config']['providers_replace']['piratebay']['replace']}")
    File.open(file_name, "w") {|file| file.puts new_contents }
  end
end

# Copy init from repo to init.d
file "/etc/init.d/sickbeard" do
  owner 'root'
  group 'root'
  mode '755'
  content lazy {::File.open("#{node['sickrage']['config']['path']}/#{node['sickrage']['init']['ubuntu']}").read}
end

# Control the call file
template '/etc/default/sickbeard'  do
	source 'sickbeardcall.erb'
	variables({
		:user => node['sickrage']['config']['user'],
		:home => node['sickrage']['config']['path'],
		:data => node['sickrage']['config']['datadir'],
		:opts => node['sickrage']['config']['options']
	})
end

# Control the PID dir
directory "/var/run/sickbeard" do
  owner node['sickrage']['config']['user']
  mode '0755'
  action :create
end

# Start the service
log "Starting SickBeard"
service "sickbeard" do
  action :start
end