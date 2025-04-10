{
  deploymentModule = ./deployment/default.nix;
  importFolder = folder: let
    b = builtins;
    files = b.readDir folder;
    fileNames = b.attrNames files;
    filesToImport =
      b.map
      (name: "${folder}/${name}")
      (b.filter (name: b.match ".*\.nix" name != null) fileNames);
  in
    filesToImport;
}