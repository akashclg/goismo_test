# AWS Deployment With GitHub Actions

This repository includes `.github/workflows/ci-cd.yml`.

The workflow runs on pull requests and pushes to `main`:

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build web --release`
- deploys `build/web` to an AWS EC2 server over SSH only after a successful push to `main`

## GitHub Secrets

Add these secrets in GitHub:

Repository `Settings` -> `Secrets and variables` -> `Actions` -> `New repository secret`.

| Secret | Value | Required |
| --- | --- | --- |
| `AWS_SSH_PRIVATE_KEY` | contents of `C:\Users\akash\Downloads\goismo-test.pem` | Yes |

The workflow is already configured to deploy to:

- host: `3.6.130.111`
- user: `ubuntu`
- port: `22`
- path: `/var/www/flutter-open-ui`

## EC2 Setup

Install nginx and rsync on the EC2 instance:

```bash
sudo apt update
sudo apt install -y nginx rsync
```

Create the deploy directory and give your deploy user permission to write to it:

```bash
sudo mkdir -p /var/www/flutter-open-ui
sudo chown -R ubuntu:ubuntu /var/www/flutter-open-ui
```

Make sure your EC2 security group allows inbound traffic on:

- `22` from your IP or GitHub Actions runners for SSH deploys
- `80` from the internet for the website

## Add The SSH Key To GitHub

Do not commit `goismo-test.pem` to this repository.

In PowerShell, copy the private key content:

```powershell
Get-Content C:\Users\akash\Downloads\goismo-test.pem -Raw
```

Create a GitHub Actions repository secret named `AWS_SSH_PRIVATE_KEY` and paste the full output, including the `BEGIN` and `END` lines.

Point nginx at the Flutter web build:

```nginx
server {
    listen 80;
    server_name _;

    root /var/www/flutter-open-ui;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

After saving the nginx site config, reload nginx:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

## Deploy

Push to `main`:

```bash
git push origin main
```

The deployment will appear in the repository's GitHub Actions tab.
