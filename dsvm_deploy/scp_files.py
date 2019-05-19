"""
Class to create an SSH client and SCP object for file transfer from a server given a username and password.
"""
import paramiko
from scp import SCPClient


class SCPFiles:
    def __init__(self, server, port, user, password):
        self.client = _createSSHClient(self.server, self.port, self.user, self.password)
        self.scp = SCPClient(self.ssh.get_transport())

    def get_files(self, file_path, download_path):
        self.scp.get(file_path, download_path)

    def _createSSHClient(server, port, user, password):
        client = paramiko.SSHClient()
        client.load_system_host_keys()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(server, port, user, password)
        return client

