# AWS Deployment With GitHub Actions

This repository includes `.github/workflows/ci-cd.yml`.

The workflow runs on pull requests and pushes to `main`:

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build web --release`
- deploys `build/web` to the nginx directory on the EC2 self-hosted runner only after a successful push to `main`

## GitHub Secrets

Add these secrets in GitHub:

Repository `Settings` -> `Secrets and variables` -> `Actions` -> `New repository secret`.

| Secret | Value | Required |
| --- | --- | --- |
| `AWS_SSH_PRIVATE_KEY` | no longer required when the runner is installed on the EC2 instance | No |

The workflow is already configured to deploy to:

- host: `3.6.130.111`
- user: `ubuntu`
- path: `/var/www/flutter-open-ui`

## Self-Hosted Runner Setup

Register the EC2 instance as a repository runner:

1. Open the repository on GitHub and go to `Settings` -> `Actions` -> `Runners` -> `New self-hosted runner`.
2. Select `Linux` and `x64`.
3. Connect to the EC2 instance as `ubuntu` and run the commands GitHub displays. GitHub provides the current runner download URL and one-time registration token.
4. When GitHub asks for labels, keep the default labels `self-hosted`, `Linux`, and `X64`.
5. Install and start the runner as a service using the commands shown by GitHub, usually:

```bash
sudo ./svc.sh install ubuntu
sudo ./svc.sh start
```

The runner must remain online. Check it under `Settings` -> `Actions` -> `Runners`; it should show `Idle` before you push code.

The workflow uses this runner for both build and deploy jobs:

```yaml
runs-on: [self-hosted, Linux, X64]
```

Install the build tools on the EC2 instance before running the workflow:

```bash
sudo apt update
sudo apt install -y git curl unzip xz-utils zip libglu1-mesa rsync nginx
```

Install Flutter using the official Linux instructions, then verify it with:

```bash
flutter --version
flutter doctor
```

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

- `22` from your IP for administration (the self-hosted runner performs deployment locally)
- `80` from the internet for the website

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
