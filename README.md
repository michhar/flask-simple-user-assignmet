# Python/Flask sample for generating DSVM logins

## Navigation

The `startup.py` file, for its part, is specifically for deploying to Azure App Service on Linux without containers. Because the app code is in its own *module* in the `login_app` folder (which has an `__init__.py`), trying to start the Gunicorn server within App Service on Linux produces an "Attempted relative import in non-package" error. The `startup.py` file, therefore, is just a shim to import the app object from the `login_app` module, which then allows you to use startup:app in the Gunicorn command line (see `startup.txt`).

## References

* [Using Flask in Visual Studio Code Tutorial](https://code.visualstudio.com/docs/python/tutorial-flask).
* [Deploy Python using Docker containers](https://code.visualstudio.com/docs/python/tutorial-deploy-containers).

## Contributing

Contributions to the sample are welcome.  Feel free to submit an issue or PR.

## Additional details

* This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
* For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or


