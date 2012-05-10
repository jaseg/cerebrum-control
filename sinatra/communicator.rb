=begin
This is the actual driver. The arduino's serial port is opened here at startup and kept open since the arduino will reset every time the serial port is reconnected (that being caused by some rs232 transmission status line/linux kernel fnord).
The lamp status is cached in a buffer and updated FRAME_RATE times per second.
TODO
This code is not (yet) thread-safe, but in case it is wanted to be... well, some mutexes should do it.
=end

require 'rubygems'
require 'serialport'
require 'pp'
require 'net/http'
require File.dirname(__FILE__)+'/jsonrpc.rb'

#possibly 20fps is a bit too much here...
FRAME_RATE = 20
LAMP_TIMEOUT = 300

#FIXME the command chars need to be checked
class Communicator

  def initialize (port)
    @sp = SerialPort.new(port, 115200)
    print "Starting up at #{Time.now}\n"
    print "##### serial port #{@sp} parameters: baudrate #{@sp.baud} port #{port}\n"
    @frame_buffer = Array.new(32, 0)
    @frame_buffer_timeouts = Array.new(32, 1)
    @lastr0ket_ts = 0
    @lastr0kets = Array.new
    Thread.new { #refresh thread
      #Apparently, when this sleep is missing, the DTR line does not go back low and the arduino is caught in an eternal reset.
      sleep 1.0
      while true
        check_timeouts
        #@sp.write("\nb\xff\xff\xff\xff\n")
        send_frame
        sleep 1.0/FRAME_RATE
      end
    }
    Thread.new { #device => host comm
      sleep 1.0
      while true
        #line = @sp.readline()
        line = "RF24 RECV 1A17181E: 0004181F (255)"
        process_command(line)
        sleep 10.0
      end
    }
    Thread.new { #Status display
      while true
        print "\nSTATUS: Last r0ket seen #{Time.now.tv_sec - @lastr0ket_ts}s ago. Last 5 r0ket ids: #{@lastr0kets}\n"
        for i in 0...32
          print "(#{@frame_buffer[i]})#{@frame_buffer_timeouts[i] == 0?"*":" "} "
        end
        print "\n"
        sleep 2.5
      end
    }
  end

  def check_timeouts ()
    for i in 0...32
      if @frame_buffer_timeouts[i] == 0
        if rand(1000) > 900
          #print "Toggling lamp #{i}\n"
          if @frame_buffer[i] == 1
            @frame_buffer[i] = 0
          else
            @frame_buffer[i] = 1
          end
        end
      else
        @frame_buffer_timeouts[i] -= 1
        if @frame_buffer_timeouts[i] == 0
          print "Timeout on lamp #{i}\n"
        end
      end
    end
  end

  def set_lamp (id, value)
    if value == 0 or value.nil? or value == false
      @frame_buffer[id] = 0
      @frame_buffer_timeouts[id] = LAMP_TIMEOUT*FRAME_RATE
    else
      @frame_buffer[id] = 1
      @frame_buffer_timeouts[id] = LAMP_TIMEOUT*FRAME_RATE
    end
  end

  def get_lamp (id)
    @frame_buffer[id]
  end

  def set_lamps (buffer)
    @frame_buffer = buffer
    for i in 0...32
      @frame_buffer_timeouts[i] = LAMP_TIMEOUT*FRAME_RATE
    end
  end

  def flash_lamp(id, duration)
    @frame_buffer[id] = (-duration*FRAME_RATE).to_i
    @frame_buffer_timeouts[id] = LAMP_TIMEOUT*FRAME_RATE
  end

  def get_lamps ()
    @frame_buffer
  end

  def send_frame ()
    cmd = "b"
    #print "b"
    for i in 0..3
      frame_data_packed = 0
      for j in 0..7
        index = i*8+j
        if @frame_buffer[index] < 0
          @frame_buffer[index] += 1
        end
        #print index if (@frame_buffer[index] != 1)
        frame_data_packed |= ((@frame_buffer[index] == 0)?0:1)<<j
      end
      cmd += frame_data_packed.chr
    end
    #puts
    cmd += "\n"
    #PP.pp(cmd)
    #print "serial port: #{@sp} @ #{@sp.baud}\n"
    @sp.write(cmd)
    #@sp.flush()
  end

  def process_command (line)
    md = /RF24 RECV ([0-9A-F]*): ([0-9A-F]*) \(([0-9]*)\)/.match(line)
    if md
      #print "r0ket seen: id #{md[1]} sequence #{md[2]} strength #{md[3]}\n"
      @lastr0kets << md[1]
      @lastr0kets.uniq!
      @lastr0kets = @lastr0kets.last(5)
      @lastr0ket_ts = Time.now.tv_sec
      JSONRPCClient.new('10.0.1.27', 4254).r0ketseen(md[1], "c_leuse", md[2], md[3])
    end
  end
  
  def set_meter (id, value)
    @sp.write("m")
    @sp.write(id)
    @sp.write(value)
    @sp.flush()
  end
end
