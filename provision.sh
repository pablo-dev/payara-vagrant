#!/bin/bash

##########################################
#
# Setting properties
#

# Which JDK to use (OPENJDK or ORACLE)
JDK="OPENJDK"

# Payara Version
PAYARA_VERSION=4.1.1.154

# Payara directory
PAYARA_HOME=/opt/payara/payara-$PAYARA_VERSION

# Postgresql lib
POSTGRESQL_LIB_URL=https://jdbc.postgresql.org/download/postgresql-9.4.1212.jar
POSTGRESQL_LIB=${POSTGRESQL_LIB_URL##*/}

# Payara Edition URLs
case "$PAYARA_VERSION" in 
	4.1.151)
		FULL=http://bit.ly/1CGCtI9
		WEB=http://bit.ly/1DmWTUY
		MINIMAL=http://bit.ly/163XP6f
		EMBEDDED_FULL=http://bit.ly/1zG59ls
		EMBEDDED_WEB=http://bit.ly/1KdVP87
		EMBEDDED_NUCLEUS=http://bit.ly/1ydQTKw
		MULTI_LANGUAGE_FULL=https://bit.ly/1zv1YeB
		MULTI_LANGUAGE_WEB=https://bit.ly/1wVXaZ
	;;
	4.1.152)
		# The below links are to 4.1.152 Patch 1
		FULL=http://bit.ly/1czs5bH
		WEB=http://bit.ly/1A2mXrq
		MINIMAL=http://bit.ly/1ICWv9p
		MICRO=http://bit.ly/1EFXzEA
		EMBEDDED_FULL=http://bit.ly/1A21MpQ
		EMBEDDED_WEB=http://bit.ly/1KMzD61
		MULTI_LANGUAGE_FULL=http://bit.ly/1H4SrdQ
		MULTI_LANGUAGE_WEB=http://bit.ly/1G8NKnd
	;;
	4.1.153)
		# The below links are to 4.1.153
		FULL=http://bit.ly/1I4tz9r
		WEB=http://bit.ly/1IaXo67
		MINIMAL=http://bit.ly/1OQGy0K
		MICRO=http://bit.ly/1JTP36N
		EMBEDDED_FULL=http://bit.ly/1h7MeZ6
		EMBEDDED_WEB=http://bit.ly/1DS74QT
		MULTI_LANGUAGE_FULL=http://bit.ly/1Sk4NKm
		MULTI_LANGUAGE_WEB=http://bit.ly/1H6pcXw
	;;
	4.1.1.154)
		# The below links are to 4.1.1.154
		FULL=http://bit.ly/1Gm0GIw
		WEB=http://bit.ly/1S0EEMI
		MINIMAL=http://bit.ly/1LrpLAz
		MICRO=http://bit.ly/1W9d2Lb
		EMBEDDED_FULL=http://bit.ly/1W8PyAw
		EMBEDDED_WEB=http://bit.ly/1Ktz9zG
		MULTI_LANGUAGE_FULL=http://bit.ly/1i0pKJm
		MULTI_LANGUAGE_WEB=http://bit.ly/1NXOVus
	;;
	PRE-RELEASE)
		# The below links are to the latest successful build
		FULL=http://payara.co.s3-website-eu-west-1.amazonaws.com/payara-prerelease.zip
		WEB=http://payara.co.s3-website-eu-west-1.amazonaws.com/payara-web-prerelease.zip
		MINIMAL=http://payara.co.s3-website-eu-west-1.amazonaws.com/payara-minimal-prerelease.zip
		MICRO=https://s3-eu-west-1.amazonaws.com/payara.co/payara-micro-prerelease.jar
		EMBEDDED_FULL=http://payara.co.s3-website-eu-west-1.amazonaws.com/payara-embedded-all-prerelease.jar
		EMBEDDED_WEB=http://payara.co.s3-website-eu-west-1.amazonaws.com/payara-embedded-web-prerelease.jar
		MULTI_LANGUAGE_FULL=https://s3-eu-west-1.amazonaws.com/payara.co/payara-ml-prerelease.zip
		MULTI_LANGUAGE_WEB=https://s3-eu-west-1.amazonaws.com/payara.co/payara-web-ml-prerelease.zip
	;;
	\*)
	echo "unknown version number"
esac

# Payara edition (Full, Web, Micro, etc., from above list)
PAYARA_ED=$WEB

#
#
##########################################


# Configure the operating system environment
configureOSE() {
	echo "Configuring operating system"

	echo "running update..."
	apt-get -qqy update                           # Update the repos

	echo "installing unzip"
	apt-get -qqy install unzip                    # Install unzip
}


# Install OpenJDK7 from Ubuntu repos
installOpenJDK7() {
	echo "Installing OpenJDK 7"
	apt-get -qqy install openjdk-7-jdk            # Install OpenJDK 7
}


# Install Oracle JDK8 via PPA from webupd8.org
installOracleJDK8() {
	echo "Installing OracleJDK 8"

        # Automate the Oracle JDK license acceptence
	echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

	add-apt-repository -y ppa:webupd8team/java    # Register the PPA
	apt-get -qqy update                           # Update the repos
	apt-get -qqy install oracle-java8-installer   # Install Oracle JDK 8
}


# Download and unzip to /opt/payara
installPayara() {
	echo "Provisioning Payara-$PAYARA_VERSION $PAYARA_ED to $PAYARA_HOME"

	echo "Downloading Payara $PAYARA_VERSION"
	wget -q $PAYARA_ED -O temp.zip > /dev/null    # Download Payara
	mkdir -p $PAYARA_HOME                         # Make dirs for Payara
	unzip -qq temp.zip -d $PAYARA_HOME            # unzip Payara to dir
        rm temp.zip                                   # cleanup temp file

        echo "Enabling secure admin mode for domains (u/p = admin/payara0payara)"
        PWDFILE=/tmp/pwdfile
        DOMAINS_DIR="${PAYARA_HOME}/payara41/glassfish/domains"
        echo "AS_ADMIN_PASSWORD=payara0payara" > ${PWDFILE}
        for DOMAIN in domain1 payaradomain; do
           echo "admin;{SSHA256}Rzyr/2/C1Zv+iZyIn/VnL0zDYESs8nTH8t/OMlOpazehMGn5L9ejkg==;asadmin" > "${DOMAINS_DIR}/${DOMAIN}/config/admin-keyfile"
           ${PAYARA_HOME}/payara41/bin/asadmin start-domain ${DOMAIN}
           ${PAYARA_HOME}/payara41/bin/asadmin --user admin --passwordfile "${PWDFILE}" enable-secure-admin
           ${PAYARA_HOME}/payara41/bin/asadmin stop-domain ${DOMAIN}
        done
        rm "${PWDFILE}"

        echo "Setting ownership of ${PAYARA_HOME} content"
	chown -R vagrant:vagrant $PAYARA_HOME         # Make sure vagrant owns dir
}


# Copy startup script, and create service
installService() {
	echo "installing startup scripts"
	mkdir -p $PAYARA_HOME/startup                 # Make dirs for Payara 
	cp /vagrant/payara_service-$PAYARA_VERSION $PAYARA_HOME/startup/ 
	chmod +x $PAYARA_HOME/startup/payara_service-$PAYARA_VERSION
	ln -s $PAYARA_HOME/startup/payara_service-$PAYARA_VERSION /etc/init.d/payara 
	
	echo "Adding payara system startup..."
	update-rc.d payara defaults > /dev/null 
	
	echo "starting Payara..."
	
	# Explicitly start payaradomain by default
	case "$PAYARA_VERSION" in
		4.1.151)
			su - vagrant -c 'service payara start domain1'
			;;
		4.1.152)
			su - vagrant -c 'service payara start payaradomain'
			;;
		4.1.153)
			su - vagrant -c 'service payara start payaradomain'
			;;
		4.1.1.154)
			su - vagrant -c 'service payara start payaradomain'
			;;
		PRE-RELEASE)
			su - vagrant -c 'service payara start payaradomain'
			;;
		/*)
			echo "Unknown Payara version, attempting to start domain1..."
			su - vagrant -c 'service payara start domain1'
	esac
}

# Download and install postgresql lib
installPostgresqlLib() {
    echo "installing postgresql lib"
    wget -q ${POSTGRESQL_LIB_URL} -O ${POSTGRESQL_LIB} > /dev/null
    for DOMAIN in domain1 payaradomain; do
        cp ${POSTGRESQL_LIB} ${PAYARA_HOME}/payara41/glassfish/domains/${DOMAIN}/lib/databases
    done
    # rm "$POSTGRE_SQL_LIB"
}

# Install the needed libraries
installLibs() {
    installPostgresqlLib
}

configureOSE

if [ "$JDK" = "ORACLE" ]; then
   installOracleJDK8
else
   installOpenJDK7
fi

installPayara

installLibs

if [ $PAYARA_ED = $WEB                 ] ||
   [ $PAYARA_ED = $FULL                ] ||
   [ $PAYARA_ED = $MULTI_LANGUAGE_FULL ] ||
   [ $PAYARA_ED = $MULTI_LANGUAGE_WEB  ]; then
	installService
fi
