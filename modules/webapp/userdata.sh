#!/bin/bash

dnf update -y

dnf install -y httpd

systemctl enable httpd
systemctl start httpd

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AIG Web Server</title>

    <style>
        body {
            margin: 0;
            padding: 0;
            background-color: #0066cc;
            font-family: Arial, sans-serif;
            color: white;
        }

        .header {
            padding: 20px;
        }

        .logo {
            height: 80px;
            width: auto;
        }

        .content {
            text-align: center;
            margin-top: 100px;
        }

        h1 {
            font-size: 2.5rem;
        }
    </style>
</head>
<body>

    <div class="header">
        <ig-logo.png
    </div>

    <div class="content">
        <h1>AIG Test Web Server deployed successfully</h1>
    </div>

</body>
</html>
EOF