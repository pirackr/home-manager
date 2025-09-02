{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs.haskellPackages; [
      ghc
      ormolu
      hoogle
      cabal-install
    ];

    programs.emacs = {
      init = {
        usePackage = {
          haskell-ts-mode = {
            enable = true;
            package = (epkgs: epkgs.haskell-ts-mode);
            mode = [ "\.hs'" "\.lhs'" ];
            custom = {
              haskell-ts-font-lock-level = 4;
              haskell-ts-use-indent = true;
              haskell-ts-ghci = "ghci";
            };
            config = ''
              (add-to-list 'treesit-language-source-alist
               '(haskell . ("https://github.com/tree-sitter/tree-sitter-haskell" "v0.23.1")))
              (unless (treesit-grammar-location 'haskell)
               (treesit-install-language-grammar 'haskell))
            '';
          };

          lsp-haskell = {
            enable = true;
            package = (epkgs: epkgs.lsp-haskell);
            hook = [ "(haskell-ts-mode . lsp)" ];
          };

          ormolu = {
            enable = true;
            package = (epkgs: epkgs.ormolu);
            hook = [ "(haskell-ts-mode . ormolu-format-on-save-mode)" ];
          };

          consult-hoogle = {
            enable = true;
          };
        };
      };
    };
  };
}

