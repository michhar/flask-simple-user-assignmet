# Python/Flask sample for generating DSVM logins

This will have two parts:  1) Deploying a multi-user Azure Data Science Virtual Machine (DSVM) with Ubuntu 2) Setting up a web app based on Flask for handing out user logins to a VM with Jupyterhub.  The final product is handy for workshops where Jupyter and a custom setup is needed.

## Deploying a multi-user Ubuntu DSVM

Create a virtual environment.

    python -m venv .env

Activate it.

    .env/bin/activate

Install Python packages.

    pip install -r requirements.txt

Set the environment variables in the current bash shell.

* Create a file `.vars` and place variables inside it.

```
export AZURE_TENANT_ID=<tenant or directory id>
export AZURE_CLIENT_ID=<client or app id>
export AZURE_CLIENT_SECRET=<app secret key>
export AZURE_SUBSCRIPTION_ID=<Azure subscription id>
export VM_USER=wonderwoman
```

* Then set all variables in the shell.

    source .vars

Run the deployment script.

    python dsvm_deploy/azure_deployment.py

## Setting up a web app based on Flask

Info on its way.  Here's a snippet of info.

The `startup.py` file, for its part, is specifically for deploying to Azure App Service on Linux without containers. Because the app code is in its own *module* in the `login_app` folder (which has an `__init__.py`), trying to start the Gunicorn server within App Service on Linux produces an "Attempted relative import in non-package" error. The `startup.py` file, therefore, is just a shim to import the app object from the `login_app` module, which then allows you to use startup:app in the Gunicorn command line (see `startup.txt`).

## References

* [Using Flask in Visual Studio Code Tutorial](https://code.visualstudio.com/docs/python/tutorial-flask).
* [Deploy Python using Docker containers](https://code.visualstudio.com/docs/python/tutorial-deploy-containers).
* [An example illustrating how to use Python to deploy an Azure Resource Manager Template](https://github.com/Azure-Samples/resource-manager-python-template-deployment)

## Contributing

Contributions to the sample are welcome.  Feel free to submit an issue or PR.

## Additional details

* This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
* For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/)


* Passwords for the VMs must have 3 of the following: 1 lower case character, 1 upper case character, 1 number, and 1 special character that is not '\' or '-'.


