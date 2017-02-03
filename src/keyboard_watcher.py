import keyboard
my_key = None
class KeyboardWatcher(object):
    def __init__(self):
        self.pressed = False
        self.keycode = 100
        self.keyname = ""

    def set_key(self, keycode, keyname):
        self.keycode = keycode
        self.keyname = keyname

    def read_key_pressed(self):
        global my_key
        my_key = None
        def record_key(event):
            if event.event_type == keyboard.KEY_UP:
                global my_key
                my_key = event

        callback = keyboard.hook(record_key)
        while my_key is None:
            pass
        keyboard.unhook(callback)
        self.keycode = int(my_key.scan_code)
        self.keyname = my_key.name
        return self.keycode, self.keyname

    def set_payloads(self, press, release):
        def on_press():
            if not self.pressed:
                press(self.keyname)
                self.pressed = True
        def on_release():
            self.pressed = False
            release()

        keyboard.hook_key(self.keycode, keydown_callback=on_press, keyup_callback=on_release)