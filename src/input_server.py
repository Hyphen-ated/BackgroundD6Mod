from Tkinter import Tk, Label

from socket_messenger import SocketMessenger
from keyboard_watcher import KeyboardWatcher
import logging


class InputServer(object):
    def __init__(self, logging_level=logging.INFO):
        self.log = logging.getLogger("input_server")
        self.log.addHandler(logging.FileHandler("../input_server_log.txt", mode='w')) # This will erase our log file from previous runs
        self.log.setLevel(logging_level)
        self.watcher = KeyboardWatcher()

    def run(self):
        messenger = SocketMessenger(9999, self)

        self.root = Tk()
        self.root.minsize(100, 50)
        self.root.geometry("600x250")
        self.root.wm_title("Background D6 Mod")
        self.root.iconbitmap(default='d6shard.ico')
        self.label = Label(self.root, text="thing")
        self.label.pack()

        self.watcher.set_payloads(self.show_input, self.release_key)

        self.root.mainloop()

    def show_input(self, key):
        print "yeah"
        self.label['text'] = key

    def release_key(self):
        print "hoboy"
        self.label['text'] = "released"

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