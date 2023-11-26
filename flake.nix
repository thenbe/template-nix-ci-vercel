{
  description = "template-nix-ci-vercel";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    playwright.url = "github:pietdevries94/playwright-web-flake/1.40.0";
  };

  outputs = { self, nixpkgs, flake-utils, playwright }: flake-utils.lib.eachDefaultSystem (system:
    let
      overlay = _final: _prev: {
        inherit (playwright.packages.${system}) playwright-test playwright-driver;
      };
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlay ];
      };
    in
    {
      devShells = {
        default = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.bashInteractive ];
          packages = [
            pkgs.nodejs_18
            pkgs.nodejs_18.pkgs.pnpm
            pkgs.nodePackages.vercel
            pkgs.playwright-test
          ];
          shellHook = ''
            export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
            export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
          '';
        };
      };
    });
}

