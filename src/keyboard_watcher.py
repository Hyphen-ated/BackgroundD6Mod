import keyboard

class KeyboardWatcher(object):
    def __init__(self):
        self.pressed = False


    def set_payloads(self, press, release):
        def on_press():
            if not self.pressed:
                press('a')
                self.pressed = True
        def on_release():
            self.pressed = False
            release()

        keyboard.hook_key('a', keydown_callback=on_press, keyup_callback=on_release)