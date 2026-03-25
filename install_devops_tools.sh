#!/bin/bash

echo "Updating system..."
dnf update -y


echo "Installing Java (JDK 17)..."
dnf install java-17-openjdk-devel -y


echo "Configuring JAVA_HOME..."

JAVA_PATH=$(dirname $(dirname $(readlink -f $(which java))))

echo "export JAVA_HOME=$JAVA_PATH" > /etc/profile.d/java.sh
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile.d/java.sh

source /etc/profile.d/java.sh


echo "Installing Git..."
dnf install git -y


echo "Installing Maven..."
dnf install maven -y


echo "Installing Tomcat..."

cd /opt

rm -f apache-tomcat-9.0.87.tar.gz

curl -L -o apache-tomcat-9.0.87.tar.gz \
https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.87/bin/apache-tomcat-9.0.87.tar.gz

tar -xzf apache-tomcat-9.0.87.tar.gz

mv apache-tomcat-9.0.87 tomcat


echo "Changing Tomcat port to 8000..."

sed -i 's/port="8080"/port="8000"/' /opt/tomcat/conf/server.xml


echo "Starting Tomcat..."

cd /opt/tomcat/bin
chmod +x *.sh
./startup.sh


echo "Installing Jenkins repository..."

wget -O /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/redhat-stable/jenkins.repo


echo "Importing Jenkins key..."

rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key


echo "Installing Jenkins..."

dnf install jenkins -y


echo "Changing Jenkins port to 8081..."

sed -i 's/JENKINS_PORT="8080"/JENKINS_PORT="8081"/' \
/usr/lib/systemd/system/jenkins.service


echo "Reloading system services..."

systemctl daemon-reexec
systemctl daemon-reload


echo "Starting Jenkins..."

systemctl enable jenkins
systemctl start jenkins


echo "Opening firewall ports..."

firewall-cmd --permanent --add-port=8000/tcp
firewall-cmd --permanent --add-port=8081/tcp
firewall-cmd --reload


echo "Checking installed versions..."

git --version
java -version
mvn -version


echo "Tomcat running at:"
echo "http://192.168.64.141:8000"


echo "Jenkins running at:"
echo "http://192.168.64.141:8081"


echo "Jenkins initial admin password:"

cat /var/lib/jenkins/secrets/initialAdminPassword


echo "Installation completed successfully!"
