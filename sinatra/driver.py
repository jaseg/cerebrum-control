
import sys
import os
import threading
import serial
from bitarray import bitarray

class MatricsDriver
    def __init__(self, port='/dev/ttyACM0', frame_rate = 50, poll_rate = 5, nleds=28, nswitches=6*4):
        self.port = serial.Serial(port, 115200)
        self.port.open()
        self.frame_buffer = bitarray(nleds)
        self.nswitches = nswitches
        self.switch_state = bitarray(nswitches)
        self.meter_values = list()
        Timer(1.0/frame_rate, send_frame);
        Timer(1.0/poll_rate, poll_switches);

    def setled(num, state):
        self.frame_buffer[num] = state;

    def getled(num, state):
        return self.frame_buffer[num]

    def setframe(buf):
        self.frame_buffer = buf

    def getframe():
        return self.frame_buffer

    def getmeter(num):
        return self.meter_values[num]
    
    def setmeter(num, value):
        self.meter_values[num] = value
        sendmeter(num)

    def sendmeter(num):
        self.serial.write('m');
        self.serial.write(num);
        self.serial.write(self.meter_values[num])
        self.serial.flush()
    
    def sendframe():
        self.serial.write('b')
        self.serial.write(self.frame_buffer.tobytes())
        self.serial.flush()

    def pollswitches():
        self.serial.write('r')
        self.switch_state = frombytes(self.serial.read((self.nswitches+7)/8))
