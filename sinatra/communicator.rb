=begin
This is the actual driver. The arduino's serial port is opened here at startup and kept open since the arduino will reset every time the serial port is reconnected (that being caused by some rs232 transmission status line/linux kernel fnord).
The lamp status is cached in a buffer and updated FRAME_RATE times per second.
TODO
This code is not (yet) thread-safe, but in case it is wanted to be... well, some mutexes should do it.
The device id for the serial port is guessed (currently).
=end

require 'rubygems'
require 'serialport'

#possibly 20fps is a bit too much here...
FRAME_RATE = 20

#FIXME the command chars need to be checked
class Communicator

  def initialize (port)
    @sp = SerialPort.new(port, 57600)
    @frame_buffer = Array.new(32, 0)
    Thread.new {
      while true
        send_frame
        poll_switches
        sleep 1.0/FRAME_RATE
      end
    }
  end

  def set_lamp (id, value)
    if value == 0 or value.nil? or value == false
      @frame_buffer[id] = 0
    else
      @frame_buffer[id] = 1
    end
  end

  def get_lamp (id)
    @frame_buffer[id]
  end

  def set_lamps (buffer)
    @frame_buffer = buffer
  end

  def get_lamps ()
    @frame_buffer
  end

  #FIXME the packed data format is still to be checked against the arduino source
  def send_frame ()
    @sp.write("b")
    for i in 0..3 do
      frame_data_packed = 0
      for j in 0..7 do
        frame_data_packed |= @frame_buffer[i*8+j]<<j
      end
      @sp.write(frame_data_packed.chr);
    end
    @sp.flush()
  end

  def poll_switches ()
    #FIXME
  end

  def set_meter(id, value)
		@sp.write("m")
		@sp.write(id)
		@sp.write(value)
		@sp.flush()
  end
end
