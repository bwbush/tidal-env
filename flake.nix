{
  description = "A Tidal Cycles project. https://tidalcycles.org/";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    tidal.url = "github:mitchmindtree/tidalcycles.nix";
    didacticpatternvisualizer = {
      url = "github:ivan-abreu/didacticpatternvisualizer";
      flake = false;
    };
  };

  outputs = inputs:
    inputs.tidal.utils.eachSupportedSystem (system:
      let
        pkgs = import inputs.nixpkgs { inherit system; overlays = [ inputs.tidal.overlays.tidal ]; };
        tidalpkgs = inputs.tidal.packages.${system};
        tidalnvim = pkgs.neovim.override {
          configure = {
            packages.myPlugins = with pkgs.vimPlugins; {
              start = [ vim-tidal ]; 
              opt = [];
            };
          };
        };
        oscP5 = pkgs.stdenv.mkDerivation {
          name = "oscP5";
          src = pkgs.fetchurl {
            url = "https://sojamo.de/libraries/oscP5/download/oscP5-0.9.8.zip";
            sha256 = "0q14ldzrskvx28vqgbs470xp88k8mji24zjiwffypbmi0c9kbwi3";
          };
          dontUnpack = true;
          buildInputs = [ pkgs.unzip ];
          installPhase = ''
            mkdir -p "$out"
            unzip -d "$out" "$src"
          '';
          meta = {
            homepage = https://sojamo.de/libraries/oscP5/;
            description = "A implementation of the OSC protocol for processing.";
            longDescription = ''
              A implementation of the OSC protocol for processing.
            '';
          };
        };
        didacticpatternvisualizer = pkgs.stdenv.mkDerivation {
          name = "didacticpatternvisualizer";
          src = inputs.didacticpatternvisualizer;
          preBuild = ''
            sed -e '18s/1280,360/1880,1040/' -i "didacticpatternvisualizer/didacticpatternvisualizer.pde"
          '';
          installPhase = ''
            mkdir -p "$out"
            cp -pr "didacticpatternvisualizer" "$out/"
          '';
          meta = {
            homepage = https://github.com/ivan-abreu/didacticpatternvisualizer/;
            description = "Didactic pattern visualizer for Tidal Cycles using Processing";
            longDescription = ''
              Sound pattern visualizer programmed in Processing by the artist Ivan Abreu to study the potential and complexity of the syntax of the pattern system for sequencing <b>Tida Cycles</b> sounds, it is also a useful tool for composing having visual feedback of ordering and sound intentions and can be a fun visual software during the live act to unfold the musical composition and with them emphasize and direct attention to the subtleties that are semi-hidden in the multiple layers created by the artist.
            '';
          };
        };
      in
        {
        # devShells = inputs.tidal.devShells.${system};
          devShells = rec {
            tidalShell = pkgs.mkShell {
              name = "tidal";
              packages = [
                tidalpkgs.supercollider
                tidalpkgs.superdirt-start
                tidalpkgs.tidal
                tidalnvim
                pkgs.processing
                oscP5
                didacticpatternvisualizer
              ];
              shellHook = ''
                mkdir -p sketchbook/libraries/
                if [[ ! -e sketchbook/libraries/oscP5/ ]]
                then
                  ln -s "${oscP5}/oscP5" sketchbook/libraries/oscP5
                fi
                if [[ ! -e sketchbook/didacticpatternvisualizer ]]
                then
                  ln -s "${didacticpatternvisualizer}/didacticpatternvisualizer" sketchbook/didacticpatternvisualizer
                fi
                alias tidalnvim="$(which nvim)"
              '';
              # Convenient access to a config providing all quarks required for Tidal.
              SUPERDIRT_SCLANG_CONF = "${tidalpkgs.superdirt}/sclang_conf.yaml";
              OSCP5_LIB="${oscP5}/oscP5";
              DIDACTICPATTERNVISUALIZER_DIR="${didacticpatternvisualizer}/didacticpatternvisualizer";
            };
            default = tidalShell;
          };
          formatter = inputs.tidal.formatter.${system};
          z = pkgs;
        }
    );

    nixConfig.bash-prompt = "\[tidal $(pwd)\]$ ";
}
