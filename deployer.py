"""A deployer class to deploy a template on Azure

This script expects that the following environment vars are set:

  AZURE_TENANT_ID: with your Azure Active Directory tenant id or domain
  AZURE_CLIENT_ID: with your Azure Active Directory Application Client ID
  AZURE_CLIENT_SECRET: with your Azure Active Directory Application Secret
"""
import os.path
import json
from haikunator import Haikunator
from azure.common.credentials import ServicePrincipalCredentials
from azure.mgmt.resource import ResourceManagementClient
from azure.mgmt.resource.resources.models import DeploymentMode
from msrestazure.azure_exceptions import CloudError


class Deployer(object):
    """ Initialize the deployer class with subscription, resource group, 
    admin name and admin password.
    :raises IOError: If the public key path cannot be read (access or not exists)
    :raises KeyError: If AZURE_CLIENT_ID, AZURE_CLIENT_SECRET or AZURE_TENANT_ID env
        variables or not defined
    """
    name_generator = Haikunator()

    def __init__(self, subscription_id, resource_group, my_admin_user, my_user_password):
        self.subscription_id = subscription_id
        self.resource_group = resource_group
        self.dns_label_prefix = self.name_generator.haikunate()
        self.vm_name = self.dns_label_prefix

        self.my_admin_user = my_admin_user
        self.my_user_password = my_user_password

        self.credentials = ServicePrincipalCredentials(
            client_id=os.environ['AZURE_CLIENT_ID'],
            secret=os.environ['AZURE_CLIENT_SECRET'],
            tenant=os.environ['AZURE_TENANT_ID']
        )
        self.client = ResourceManagementClient(self.credentials, self.subscription_id)

    def deploy(self):

        try:
            """Deploy the template to a resource group."""
            self.client.resource_groups.create_or_update(
                self.resource_group,
                {
                    'location':'westus2'
                }
            )
        except CloudError as err:
            print(err, ' and moving on.')

        template_path = os.path.join(os.path.dirname(__file__), 'arm_templates', 'azuredeploy.json')
        with open(template_path, 'r') as template_file_fd:
            template = json.load(template_file_fd)

        parameters = {
            'adminUsername': self.my_admin_user,
            'adminPassword': self.my_user_password,
            'vmName': self.vm_name,
            'dnsLabelPrefix': self.dns_label_prefix,
            'vmSize': 'Standard_NC6'
        }
        parameters = {k: {'value': v} for k, v in parameters.items()}

        deployment_properties = {
            'mode': DeploymentMode.incremental,
            'template': template,
            'parameters': parameters
        }

        deployment_async_operation = self.client.deployments.create_or_update(
            self.resource_group,
            'azure-sample',
            deployment_properties
        )
        deployment_async_operation.wait()

    def destroy(self):
        """Destroy the given resource group"""
        self.client.resource_groups.delete(self.resource_group)