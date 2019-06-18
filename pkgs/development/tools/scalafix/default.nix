{ stdenv, jdk, jre, coursier, makeWrapper }:

let
  baseName = "scalafix";
  version = "0.9.5";
  deps = stdenv.mkDerivation {
    name = "${baseName}-deps-${version}";
    buildCommand = ''
      export COURSIER_CACHE=$(pwd)
      ${coursier}/bin/coursier fetch ch.epfl.scala:scalafix-cli_2.12.8:${version} > deps
      mkdir -p $out/share/java
      cp -n $(< deps) $out/share/java/
    '';
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash     = "192vw50rs9dd1v7amgy4jxzpp9rfpy1kysj5lbzgbjl0gjgfwgw3";
  };
in
stdenv.mkDerivation {
  name = "${baseName}-${version}";

  buildInputs = [ jdk makeWrapper deps ];

  doCheck = true;

  phases = [ "installPhase" "checkPhase" ];

  installPhase = ''
    makeWrapper ${jre}/bin/java $out/bin/${baseName} \
      --add-flags "-cp $CLASSPATH scalafix.cli.Cli"
  '';

  checkPhase = ''
    $out/bin/${baseName} --version | grep -q "${version}"
  '';

  meta = with stdenv.lib; {
    description = "Refactoring and linting tool for Scala";
    homepage = "https://scalacenter.github.io/scalafix/";
    license = licenses.bsd3;
    maintainers = [ maintainers.tomahna ];
  };
}
