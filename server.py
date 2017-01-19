import socket
import sys, signal

import time
from pynput.keyboard import Key, Listener, KeyCode


def signal_handler(signal, frame):
    print("\nClosing")
    sys.exit(0)
    
signal.signal(signal.SIGINT, signal_handler)

HOST = ''
PORT = 9998

print 'Starting'

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.bind((HOST, PORT))

print 'Started'


input_pressed = False
last_press = time.time()
def on_press(key):
    pass
def on_release(key):
    try:
        global input_pressed
        global last_press
        cur_time = time.time()
        if key == Key.f13 and cur_time - 0.2 > last_press:
            print "Swap Items"
            last_press = cur_time
            try:
                s.sendto('A',('127.0.0.1',9999))
            except Exception as e:
                print e.message
        # elif key == Key.esc: # TODO maybe keep a way to end it but this was annoying in testing
        #     return False
    except Exception as e:
        print "Exception"

listener = Listener(
        on_press=on_press,
        on_release=on_release)


listener.start()
listener.join()

