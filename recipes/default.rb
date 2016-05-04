#
# Cookbook Name:: truesight-events
# Recipe:: default
#
# Copyright (C) 2016 BMC Software
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe 'chef_handler'

email = node['truesight_events']['email']
token = node['truesight_events']['api_token']

begin
  email = databag('truesight', 'account')['email'] if email.empty?
rescue
  log 'TrueSight Events Error' do
    level :error
    message 'Authentication Email not set and TrueSight Databag not found'
  end

  return
end

begin
  token = databag('truesight', 'account')['api_token'] if token.empty?
rescue
  log 'TrueSight Events Error' do
    level :error
    message 'API Token not set and TrueSight Databag not found'
  end

  return
end

cookbook_file "#{Chef::Config[:file_cache_path]}/truesight-events-handler.rb" do
  source "truesight-events-handler.rb"
  mode "0600"
end

chef_handler "TrueSightEvents" do
  source "#{Chef::Config[:file_cache_path]}/truesight-events-handler.rb"
  arguments [:email => email, :api_token => token]
  action :enable
end
