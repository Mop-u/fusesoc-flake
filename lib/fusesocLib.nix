{
    lib,
    remarshal,
    runCommand,
}:
{
    parseVlnv =
        vlnv:
        let
            split = lib.splitString ":" vlnv;
        in
        if builtins.length split == 4 then
            {
                vendor = builtins.elemAt split 0;
                library = builtins.elemAt split 1;
                name = builtins.elemAt split 2;
                version = builtins.elemAt split 3;
            }
        else
            builtins.throw "Unable to parse vlnv ${vlnv}. Expected format: `vendor:library:name:version`. If the core has no version use 0.";
    readYAML =
        path:
        let
            jsonFile =
                runCommand "from-yaml-${builtins.baseNameOf path}"
                    {
                        nativeBuildInputs = [ remarshal ];
                    }
                    ''
                        remarshal -k -if yaml -i "${path}" -of json -o "$out"
                    '';
        in
        builtins.fromJSON (builtins.readFile jsonFile);
}
