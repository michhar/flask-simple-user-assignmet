# A Web App for Distributing Logins to JupyterHub Running on an Azure VM

This project is a WIP.  It will have two parts:  

1) Programmatically deploy a multi-user <a href="https://docs.microsoft.com/en-us/azure/machine-learning/data-science-virtual-machine/" target="_blank">Azure Data Science Virtual Machine (DSVM)</a> with Ubuntu for working with PyTorch and other deep learning frameworks through Jupyter

2) Setting up a web app based on Flask for handing out user logins to a VM with <a href="https://jupyterhub.readthedocs.io/en/stable/" target="_blank">JupyterHub</a>

The final product is handy for workshops where Jupyter and a multi-user setup is needed.

## What gets deployed

* NC6 Ubuntu Data Science Virtual Machine with JupyterHub and <a href="https://pytorch.org/" target="_blank">PyTorch</a> kernels (1, 0.4.1, 0.3.1)
* Azure App Service for Flask webapp
* AAD App with a Service Principal

## Prerequisites

* These <a href="https://code.visualstudio.com/docs/python/tutorial-deploy-app-service-on-linux#_prerequisites" target="_blank">Prerequisites for Deploy to Azure App Service on Linux tutorial</a> which includes Python 3 (tested with 3.6) and an account on Azure - see link for complete list
* Git

## Deploying a multi-user Ubuntu DSVM

But first, here are some more details on the VM.

* Multiple users are created
  * 1 admin ("superwoman" is the default name or otherwise provided in the `VM_USER` environment var) and 10 users with sudoer permissions (so that they can `pip` install)
  * The admin and users have randomly generated passwords.  The admin password is given when running the Python deployment script.  The list for the additional users and corresponding passwords is downloaded automatically as a `csv` file after running the deployment script.
  * Each user will have a home folder with the generic notebooks that come with the VM by default - so essentially their own working environment.
* JupyterHub is provided for multi-tenant login
* PyTorch 1.0, 0.4.1, and 0.3.1 kernels for Jupyter are created

### Steps

Clone this repository in Git bash or bash terminal:

    git clone https://github.com/michhar/workshop-dsvm-and-webapp.git

Open up VS Code to the repository folder.

Go to **Terminal -> New Terminal** to open up a terminal window.

Create a virtual environment (assuming Python 3.6 is installed):

    python3.6 -m venv .env

Activate it:

    .env/bin/activate

Install Python packages:

    pip install -r requirements.txt

Create an AAD app and Service Principal in Azure Portal for authentication.

* Follow [How to: Use the portal to create an Azure AD application and service principal that can access resources](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)

Create a file `.vars` and place environment variables inside it.

* For example, the Unix file will look like:

```
export AZURE_TENANT_ID=<tenant or directory id>
export AZURE_CLIENT_ID=<client or app id>
export AZURE_CLIENT_SECRET=<app secret key>
export AZURE_SUBSCRIPTION_ID=<Azure subscription id>
export VM_USER=wonderwoman
```

* The Windows file will look like:

```
set AZURE_TENANT_ID <tenant or directory id>
set AZURE_CLIENT_ID <client or app id>
set AZURE_CLIENT_SECRET <app secret key>
set AZURE_SUBSCRIPTION_ID <Azure subscription id>
set VM_USER wonderwoman
```

Set the variables in the shell in Unix as follows (in Windows take away the `source` command):

    source .vars

Run the deployment script:

    .env/bin/python dsvm_deploy/azure_deployment.py

**IMPORTANT NOTE:** Make sure to "Stop" the VM when not in use to avoid incurring charges for it.  This can be done in the Azure Portal

## Setting up a web app based on Flask

This is currently being implemented.  It will be based on this <a href="https://code.visualstudio.com/docs/python/tutorial-deploy-app-service-on-linux" target="_blank">Tutorial</a>.

### Steps

When first getting to this repository, test locally.

    gunicorn --bind=0.0.0.0 --timeout 600 startup:app

* Navigate to the indicated URL to see the web app in action (`flask run` could also be used for testing, but since `gunicorn` is used by App Service, it's nice to test it that way).


### Purpose of files

The `startup.py` file, for its part, is specifically for deploying to Azure App Service on Linux without containers. Because the app code is in its own *module* in the `login_app` folder (which has an `__init__.py`), trying to start the Gunicorn server within App Service on Linux produces an "Attempted relative import in non-package" error. The `startup.py` file, therefore, is just a shim to import the app object from the `login_app` module, which then allows you to use startup:app in the Gunicorn command line (see `startup.txt`).  As the tutorial indicates under <a href="https://code.visualstudio.com/docs/python/tutorial-deploy-app-service-on-linux#_configure-a-custom-startup-file" target="_blank">Configure a custom startup file</a>, the `startup.txt` will need to be placed in the App Service's **Configuration -> General settings -> Starup Command** (just go to the App Service in the Azure Portal to do this).

## References

* [Using Flask in Visual Studio Code Tutorial](https://code.visualstudio.com/docs/python/tutorial-flask).
* [Deploy Python using Docker containers](https://code.visualstudio.com/docs/python/tutorial-deploy-containers).
* [An example illustrating how to use Python to deploy an Azure Resource Manager Template](https://github.com/Azure-Samples/resource-manager-python-template-deployment)

## Contributing

Contributions to the sample are welcome.  Feel free to submit an issue or PR.

## Additional details

* This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
* For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/)


## Troubleshooting

* The `CryptographyDeprecationWarning` is a known issue.
* Occasionally, the VM has an issue with deployment and an scp error will show up (`paramiko.ssh_exception.NoValidConnectionsError`).  In this case, please delete the resource group in the Azure Portal and try the deployment agin.
* Passwords for the VMs must have 3 of the following: 1 lower case character, 1 upper case character, 1 number, and 1 special character that is not '\' or '-'.
* To check for the user accounts present on the VM, ssh into the VM, and use the following command:

    * `cut -d: -f1 /etc/passwd`


