{
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };
    outputs = {self, nixpkgs, flake-utils}:
    let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};

        pname = "spacedrive";
        version = "0.4.2";

        src = pkgs.fetchurl {
            url = "https://github.com/spacedriveapp/spacedrive/releases/download/${version}/Spacedrive-linux-x86_64.AppImage";
            hash = "sha256-JFSbqzCDjG2bQ4ZO5P/fm6FXB93MWUu0aM4k0azbEgU=";
        };

    in {
        packages.${pname} = pkgs.stdenvNoCC.mkDerivation {
            meta = {
                description = "An open source file manager, powered by a virtual distributed filesystem";
                homepage = "https://www.spacedrive.com";
                changelog = "https://github.com/spacedriveapp/spacedrive/releases/tag/${version}";
                platforms = [ "x86_64-linux" ];
                license = nixpkgs.lib.licenses.agpl3Plus;
                sourceProvenance = with nixpkgs.lib.sourceTypes; [ binaryNativeCode ];
                mainProgram = pname;
            };
            dontConfigure = true;
            dontBuild = true;

            nativeBuildInputs = with pkgs; [
                dpkg
                autoPatchelfHook
            ];
            
            unpackPhase = ''
                ${pkgs.dpkg}/bin/dpkg-deb -x $src $out
            '';

            patchPhase = ''

            '';

            installPhase = ''
                runhook preInstall

                mv $out/usr/* $out
                rm -rf $out/usr

                runhook postInstall
            '';
        };
    };
}

#''
#    # Install .desktop files
#    install -Dm444 ${appimageContents}/com.spacedrive.desktop -t $out/share/applications
#    install -Dm444 ${appimageContents}/spacedrive.png -t $out/share/pixmaps
#    substituteInPlace $out/share/applications/com.spacedrive.desktop \
#        --replace 'Exec=usr/bin/spacedrive' 'Exec=spacedrive'
#'';
