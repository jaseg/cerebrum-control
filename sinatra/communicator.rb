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
FRAME_RATE = 20 unless FRAME_RATE

class Communicator

  def initialize (port)
    @sp = SerialPort.new(port, 115200)
    @frame_buffer = Array.new()
    Thread.start do
      while true
        send_frame
        poll_switches
        sleep 1.0/FRAME_RATE
      end
    end
  end

  def set_frame (frameData)
    @frame_buffer = frameData
  end

  def set_lamp (id, value)
    @frame_buffer[id] = value
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

  def send_frame ()

  end

  def poll_switches ()

  end

  def set_meter(id, value)
    send_command ("m" id value)
  end
end
