# grok-cli-nix

Nix-пакет [Grok CLI](https://x.ai/cli) (xAI) из официального бинарного релиза.

Один static-pie бинарь с `https://x.ai/cli/grok-<version>-<platform>`,
версия — из channel-pointer `https://x.ai/cli/stable`.
Автоапдейтер CLI отключён (`GROK_AUTO_UPDATE=0`) — обновляет крон-воркфлоу.

```nix
grokSrc = builtins.fetchTarball {
  url = "https://github.com/farwydi/grok-cli-nix/archive/refs/heads/master.tar.gz";
};
grok = (import <nixpkgs> {
  inherit (pkgs.stdenv.hostPlatform) system;
  config.allowUnfree = true;
}).callPackage "${grokSrc}/package.nix" { };
```
