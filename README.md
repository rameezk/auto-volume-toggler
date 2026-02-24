# Auto Volume Toggler

Sets MacBook Pro Speakers volume to a specified target when no audio is playing.

## Usage

```bash
nix run github:rameezk/auto-volume-toggler
```

## Automation with nix-darwin

You can run this automatically every 5 minutes using a launchd user agent. Add the following to your nix-darwin configuration:

```nix
{ pkgs, ... }:

{
  launchd.user.agents.auto-volume-toggler = {
    serviceConfig = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        ''echo "$(date '+%Y-%m-%d %H:%M:%S') - Running auto-volume-toggler" && ${pkgs.nix}/bin/nix run github:rameezk/auto-volume-toggler 2>&1''
      ];
      StartInterval = 300; # 5 minutes
      StandardOutPath = "/tmp/auto-volume-toggler.log";
      StandardErrorPath = "/tmp/auto-volume-toggler.log";
    };
  };
}
```

Then rebuild your system:

```bash
darwin-rebuild switch --flake <path-to-your-flake>
```

Verify it's running:

```bash
launchctl list | grep auto-volume
cat /tmp/auto-volume-toggler.log
```
