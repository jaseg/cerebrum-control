#!/usr/bin/env ruby
require 'pcaplet'
require File.dirname(__FILE__)+'/jsonrpc.rb'

startport_flash = 32769
startport_off = 32801
startport_on = 32833
nlamps = 26
flash_duration = 0.5
com = JSONRPCClient.new('10.0.1.27', 4567, "/jsonrpc")
@pcl = Pcaplet.new
@pcl.add_filter Pcap::Filter.compile("udp", @pcl.capture)
@pcl.each_packet do |pkg|
  next unless pkg.udp?
  if (startport_flash..(startport_flash+nlamps)).include? pkg.dport
    lid = pkg.dport-startport_flash
    print Time.now
    puts " flashing lamp #{lid}"
    com.flash_lamp(lid, flash_duration)
  end
  if (startport_on..(startport_on+nlamps)).include? pkg.dport
    lid = pkg.dport-startport_on
    print Time.now
    puts " switching on lamp #{lid}"
    com.set_lamp(lid, 1)
  end
  if (startport_off..(startport_off+nlamps)).include? pkg.dport
    lid = pkg.dport-startport_off
    print Time.now
    puts " switching off lamp #{lid}"
    com.set_lamp(lid, 0)
  end
end
