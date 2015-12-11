# README #

Vagrantfile for Payara.

Currently it uses ubuntu/trusty64 as a base and gets the Java EE Web profile of Payara 4.1.1.154, extracting to /opt/payara/payara-$PAYARA_VERSION.  The provision.sh script contains PAYARA_VERSION and PAYARA_ED variables which can be changed to point to a different version/edition of Payara.

By default, OpenJDK 7 is installed, since that is the latest Java currently available in the Ubuntu repos.  The `JDK` variable can be changed in the provision.sh script to choose to install Oracle JDK 8 instead of OpenJDK.

During provisioning, both domains (`domain1` and `payaradomain`) are configured to enable secure admin mode with a username of `admin` and password of `payara0payara`.

There is still work to be done, but at this point, the file is usable for development/testing purposes.

### WARNING
The installation scripts will work with any Payara (simply specify `FULL` or `MICRO` etc on the `wget` line) but the configuration script to install Payara as a service will ***NOT*** work with the embedded/micro/nucleus versions. (They're just JARs...what would you expect??)

Pull requests welcome.
