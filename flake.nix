{
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

        systems.url = "github:nix-systems/x86_64-linux";
        
        flake-utils.url = "github:numtide/flake-utils";
        flake-utils.inputs.systems.follows = "systems";
    };

    outputs = {self, nixpkgs, flake-utils, ...}: flake-utils.lib.eachDefaultSystem (system: 
    let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
        version = "0.4.2";
    in {
        packages.spacedrive = pkgs.stdenvNoCC.mkDerivation {
            name = "spacedrive";
            version = version;
            dontBuild = true;
            dontConfigure = true;

            src = pkgs.fetchurl {
                url = "https://github.com/spacedriveapp/spacedrive/releases/download/${version}/Spacedrive-linux-x86_64.deb";
                hash = "sha256-JFSbqzCDjG2bQ4ZO5P/fm6FXB93MWUu0aM4k0azbEgU=";
            };

            nativeBuildInputs = with pkgs; [
                dpkg
                autoPatchelfHook
            ];
            
            unpackPhase = ''
                ${pkgs.dpkg}/bin/dpkg-deb -x $src $out
            '';

            installPhase = ''
                runhook preInstall

                mv $out/usr/* $out
                rm -rf $out/usr

                runhook postInstall
            '';

            system = builtins.currentSystem;

            meta = {
                description = "An open source file manager, powered by a virtual distributed filesystem";
                homepage = "https://www.spacedrive.com";
                changelog = "https://github.com/spacedriveapp/spacedrive/releases/tag/${version}";
            };
        };
    });
}

#''
#    # Install .desktop files
#    install -Dm444 ${appimageContents}/com.spacedrive.desktop -t $out/share/applications
#    install -Dm444 ${appimageContents}/spacedrive.png -t $out/share/pixmaps
#    substituteInPlace $out/share/applications/com.spacedrive.desktop \
#        --replace 'Exec=usr/bin/spacedrive' 'Exec=spacedrive'
#'';
