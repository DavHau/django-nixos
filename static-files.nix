{ pkgs,
  src,
  python,
  settings,
  name ? "",
  manage-py ? "${src}/manage.py",
  ... }:

pkgs.runCommand 
  "${name}-static"
  { buildInputs = [ src python ]; }
  ''mkdir $out
    export SECRET_KEY="key"  # collectstatic doesn't care about the key (with our whitenoise settings)
    export STATIC_ROOT=$out
    ${python}/bin/python ${manage-py} collectstatic --settings ${settings}
  ''