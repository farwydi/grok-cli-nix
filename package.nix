{
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  lib,
}:

let
  sources = builtins.fromJSON (builtins.readFile ./sources.json);
  system = stdenvNoCC.hostPlatform.system;
  entry = sources.systems.${system} or (throw "grok-cli: unsupported system ${system}");
in
stdenvNoCC.mkDerivation {
  pname = "grok-cli";
  version = sources.version;

  # один static-pie бинарь с CDN x.ai, запускается без patchelf
  src = fetchurl {
    url = "https://x.ai/cli/grok-${sources.version}-${entry.target}";
    hash = entry.hash;
  };

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    install -Dm755 $src $out/bin/grok
    wrapProgram $out/bin/grok \
      --set GROK_AUTO_UPDATE 0
  '';

  meta = {
    mainProgram = "grok";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    license = lib.licenses.unfree;
  };
}
