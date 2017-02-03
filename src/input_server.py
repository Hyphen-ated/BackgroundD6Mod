from Tkinter import Tk, Label, Button

from socket_messenger import SocketMessenger
from keyboard_watcher import KeyboardWatcher
import logging

our_port = 9998
isaac_port = 9999


class InputServer(object):
    def __init__(self, logging_level=logging.INFO):
        self.log = logging.getLogger("input_server")
        self.log.addHandler(logging.FileHandler("../input_server_log.txt", mode='w')) # This will erase our log file from previous runs
        self.log.setLevel(logging_level)
        self.watcher = KeyboardWatcher()

    def run(self):
        self.messenger = SocketMessenger(our_port, isaac_port, self)

        self.root = Tk()
        self.root.minsize(100, 50)
        self.root.geometry("600x250")
        self.root.wm_title("Background D6 Mod")
        self.root.iconbitmap(default='d6shard.ico')

        def set_key():
            self.label['text'] = "Press new key... "
            self.root.update()
            keycode, keyname = self.watcher.read_key_pressed()
            self.label['text'] = "Key set to '" + keyname + "'"
            self.root.update()
            self.watcher.set_payloads(self.show_input, self.release_key)

        self.button = Button(self.root, text="Set Reroll Key", command=set_key)
        self.button.pack()

        self.label = Label(self.root, text="")
        self.label.pack()


        self.watcher.set_payloads(self.show_input, self.release_key)

        self.root.mainloop()


    def show_input(self, keyname):
        self.label['text'] = "'" + keyname + "' pressed"
        self.messenger.send_socket_message("A")

    def release_key(self, keyname):
        self.label['text'] = "'" + keyname + "' not pressed"

    def log_error(self, msg):
        # Print it to stdout for dev troubleshooting, log it to a file for production
        print(msg)
        self.log.error(msg)



def main():
    try:
        server = InputServer()
        server.run()
    except Exception:
        import traceback
        errmsg = traceback.format_exc()
        server.log_error(errmsg)

if __name__ == "__main__":
    main()