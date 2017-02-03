import socket


class SocketMessenger(object):
    def __init__(self, port, input_server):
        self.port = port
        self.input_server = input_server
        self.sock = None

    def run(self):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.sock.bind(("127.0.0.1", self.port))


    def send_socket_message(self, msg):
        try:
            self.sock.sendto(msg,('127.0.0.1',9999))
        except Exception as e:
            self.input_server.log_error(e.message)


