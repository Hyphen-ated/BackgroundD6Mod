import socket


class SocketMessenger(object):
    def __init__(self, our_port, isaac_port, input_server):
        self.isaac_port = isaac_port
        self.input_server = input_server
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.sock.bind(("127.0.0.1", our_port))

    def send_socket_message(self, msg):
        try:
            self.sock.sendto(msg,('127.0.0.1',self.isaac_port))
        except Exception as e:
            self.input_server.log_error(e.message)


