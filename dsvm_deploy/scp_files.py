"""
Class to create an SSH client and SCP object for file transfer from a server given a username and password.
"""
import paramiko
from scp import SCPClient


class SCPFiles:
    def __init__(self, server, port, user, password):
        self.user = user
        self.password = password
        self.server = server
        self.port = 22

    def get_file(self, file_path, download_path):
        client = self._createSSHClient()
        scp = SCPClient(client.get_transport())
        scp.get(file_path, download_path)

    def _createSSHClient(self):
        client = paramiko.SSHClient()
        client.load_system_host_keys()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(self.server, self.port, self.user, self.password)
        return client

