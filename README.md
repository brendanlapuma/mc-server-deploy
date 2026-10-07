# Minecraft server deployment

This repository contains the files for a modded Minecraft server and deploys them to an existing Google Cloud VM.

## Runtime model

The server runs in one named `tmux` session on the VM. GitHub Actions sends the Minecraft `stop` command to that session, waits for it to exit, starts the new server in the same detached session, and follows the server log until the configured startup message appears. The action then exits while the server continues running.

To administer the server interactively:

```bash
ssh minecraft@VM_HOST
tmux attach -t minecraft
```

Detach without stopping the server with `Ctrl-b`, then `d`.

## VM setup

The VM should be a Linux instance with a user that can run the server. Install a Java runtime compatible with the selected Minecraft/mod-loader version, then run:

```bash
sudo apt-get update
sudo apt-get install -y coreutils tmux
git clone https://github.com/OWNER/REPOSITORY.git /tmp/mc-server-deploy
sudo /tmp/mc-server-deploy/.github/scripts/setup-vm.sh
```

The setup script creates `/srv/minecraft`, makes the current user its owner, and checks that `java` and `tmux` are available. The server's `run.sh` and `user_jvm_args.txt` are deployed with the repository.

## GitHub repository configuration

Add these repository **secrets**:

| Secret | Description |
| --- | --- |
| `MC_VM_HOST` | VM IP address or DNS name |
| `MC_VM_USER` | Linux user that owns and runs the server |
| `MC_VM_SSH_KEY` | Private SSH key for that user |

The readiness pattern is configured directly in `.github/workflows/deploy.yml` as `MC_READY_PATTERN`. Replace the temporary `<LOG PATTERN HERE>` placeholder with the exact text from the server log that means the server is ready.

Pushes to `main` use `4G` of RAM. Manual runs can choose the RAM amount from the workflow's **Run workflow** menu: `2G`, `4G`, `6G`, `8G`, or `16G`.

The workflow writes the selected maximum RAM to the active `-Xmx` entry in `user_jvm_args.txt`, then starts the server through the repository's built-in script:

```text
bash run.sh nogui
```

The workflow runs on every push to `main`. It archives the repository, uploads it over SSH, stops the existing server, updates `user_jvm_args.txt`, starts the server with `.github/scripts/start-server.sh`, and streams startup output into the Actions log while waiting for `MC_READY_PATTERN`. The shared shutdown logic is in `.github/scripts/stop-server.sh`; the VM port, server directory, and tmux session are fixed internal deployment settings.

To stop the server without deploying, open the **Stop Minecraft server** workflow under the repository's **Actions** tab and select **Run workflow**. It sends the normal `stop` command to the server and force-terminates the tmux session if shutdown takes longer than 60 seconds.

## Repository contents

Commit the Minecraft server jar, mod files, configuration, and any required startup assets to this repository. Do not commit private keys, operator credentials, or other secrets.
