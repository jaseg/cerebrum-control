require 'pcaplet'

class LEDPcap
  def initialize (startport, nlamps, flash_duration, com)
    @pcl = Pcaplet.new
    @pcl.add_filter Pcap::Filter.compile("udp", @pcl.capture)
    Thread.new do
      @pcl.each_packet {|pkg|
        next unless pkg.udp?
        if (startport..(startport+nlamps)).include? pkg.dport
          puts "UDP event on port #{pkg.dport}"
          com.flash_lamp(pkg.dport-startport, flash_duration)
        end
      }
    end
  end
end
