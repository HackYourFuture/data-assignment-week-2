# Logging in to Azure

The Week 2 assignment requires access to the HackYourFuture Azure tenant to upload files to Azure Blob Storage (Task 3).

## In GitHub Codespaces

The Azure CLI is pre-installed in this Codespace. You only need to authenticate.

Run the following command in the Codespace terminal:

```bash
az login --use-device-code
```

You will see output like:

```text
To sign in, use a web browser to open the page https://microsoft.com/devicelogin
and enter the code XXXXXXXX to authenticate.
```

1. Open [microsoft.com/devicelogin](https://microsoft.com/devicelogin) in your browser.
2. Enter the code shown in the terminal.
3. Sign in with the HackYourFuture credentials your teacher provided (format: `firstname.lastname@hackyourfuture.net` or similar).
4. Return to the Codespace terminal. You should see your account details printed.

Verify the login succeeded:

```bash
az account show --query "{user:user.name, subscription:name, tenant:homeTenantId}" --output table
```

The `user` field should show your HackYourFuture account email.

## On your local machine

If you are working locally and the Azure CLI is already installed from Week 1, run:

```bash
az login
```

This opens a browser window for you to sign in. After signing in, return to the terminal and verify with the command above.

If `az` is not installed, follow the [official installation guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) for your OS, then run `az login`.

## Troubleshooting

**"The subscription is not in the HackYourFuture tenant"**: You are logged in with a personal or work account. Run `az logout`, then `az login --use-device-code` again and use the HYF credentials.

**"Authorization failed" on storage commands**: Your account may not have the `Storage Blob Data Contributor` role on `sthyfstudentsdemo`. Contact your teacher.

**Code expired**: The device login code is valid for 15 minutes. If it expires, re-run `az login --use-device-code` to get a new one.
