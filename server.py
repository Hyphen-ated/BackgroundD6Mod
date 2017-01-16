import socket
import struct
import sys, signal
from pynput.keyboard import Key, Listener, KeyCode


def signal_handler(signal, frame):
    print("\nClosing")
    sys.exit(0)
    
signal.signal(signal.SIGINT, signal_handler)

HOST = ''
PORT = 9999

print 'Starting'

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((HOST, PORT))
s.listen(1)

print 'Started'

conn, addr = s.accept()


input_pressed = False

def on_press(key):
    pass
def on_release(key):
    try:
        global input_pressed
        if key == KeyCode.from_char("o"):
            print "Swap Items"
            input_pressed = True
        elif key == Key.esc:
            return False
    except Exception as e:
        print "Exception"

listener = Listener(
        on_press=on_press,
        on_release=on_release)

# TODO i dont understand how really any of this server code works

listener.start()
# listener.join()


while 1:
    global input_pressed
    data = conn.recv(1024)
    tosend = "A" if input_pressed else "C"
    conn.send(tosend)
    input_pressed = False

conn.close()