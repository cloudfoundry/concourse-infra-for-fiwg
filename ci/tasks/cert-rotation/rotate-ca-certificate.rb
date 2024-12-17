#!/usr/bin/env ruby

require 'json'
require 'tempfile'
require 'uri'
require 'openssl'
require 'cgi/util'

jumpbox_private_key = Tempfile.new
jumpbox_private_key.write(ENV['JUMPBOX_PRIVATE_KEY'])
jumpbox_private_key.close

ENV['CREDHUB_PROXY'] = "ssh+socks5://jumpbox@#{ENV['JUMPBOX_URL']}?private-key=#{jumpbox_private_key.path}"

@cert_by_id = Hash.new do |h, certificate_id|
  cert_data = JSON.parse(`credhub curl -p 'api/v1/data/#{certificate_id}'`)['value']['certificate']
  cert = OpenSSL::X509::Certificate.new(cert_data)

  h[certificate_id] = cert
end

def clean_old_versions(certificate_data)
  certificate_name = certificate_data['name']
  versions_to_remove = certificate_data['versions'][3..-1]
  if versions_to_remove
    puts "#{certificate_name}: Removing #{versions_to_remove.length} old versions"
    versions_to_remove.each do |version|
      `credhub curl -p /api/v1/certificates/#{certificate_data['id']}/versions/#{version['id']} -X DELETE`
    end
  end
end

def cert_signed_by_ca?(certificate_id, ca_id)
  store = OpenSSL::X509::Store.new
  store.add_cert(@cert_by_id[ca_id])
  store.verify(@cert_by_id[certificate_id])
end

def fetch_data(cert_name)
  escaped_name = CGI.escape(cert_name)
  JSON.parse(`credhub curl -p 'api/v1/certificates?name=#{escaped_name}'`)['certificates'].first
end

ENV['CAS_TO_ROTATE'].split(/[ ,]/).each do |ca_name|
  ca_data = fetch_data(ca_name)
  leafs = ca_data['signs'].collect { |leaf| fetch_data(leaf) }
  leafs_signed_by_current_version = leafs.all? do |leaf|
    cert_signed_by_ca?(leaf['versions'][0]['id'], ca_data['versions'][0]['id'])
  end

  if leafs_signed_by_current_version
    current_ca_transitional = ca_data['versions'][0]['transitional']
    puts "#{ca_name}: Regenerating"
    if current_ca_transitional
      puts "#{ca_name}: Found transitional version, removing transitional flag"
      `credhub curl -p 'api/v1/certificates/#{ca_data['id']}/update_transitional_version' -X PUT -d '{"version": null}'`
    end
    `credhub curl -p 'api/v1/certificates/#{ca_data['id']}/regenerate' -X POST -d '{"set_as_transitional": true}'`
    clean_old_versions(ca_data)
  else
    puts "#{ca_name}: Leafs found using previous version, skipping regeneration"
  end

  leafs_should_be_signed_by_transitional_ca = !leafs_signed_by_current_version
  leafs.each do |leaf_data|
    puts "#{leaf_data['name']}: Regenerating#{" using transitional CA" if leafs_should_be_signed_by_transitional_ca}"
    `credhub curl -p 'api/v1/certificates/#{leaf_data['id']}/regenerate' -X POST -d '{"allow_transitional_parent_to_sign": #{leafs_should_be_signed_by_transitional_ca}}'`
    clean_old_versions(leaf_data)
  end
end
