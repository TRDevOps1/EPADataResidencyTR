#!/bin/bash

dnf update -y

dnf install -y httpd

systemctl enable httpd
systemctl start httpd

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
<title>Terraform Demo</title>
</head>
<body>
<h1>Hello from Terraform!</h1>
<p>This website is running on immutable EC2 infrastructure.</p>
</body>
</html>
EOF