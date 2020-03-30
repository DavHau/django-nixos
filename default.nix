{ # MANDATORY
  name,  # create a name for the project
  keys-file,  # path to a file containing secrets
  src,  # derivation of django source code

  # OPTIONAL
  settings, # django settings module like `myproject.settings`
  pkgs ? import ./nixpkgs-src.nix { config = {}; },  # nixpkgs
  python ? import ./python.nix { inherit pkgs; },  # python + modules
  manage-py ? "${src}/manage.py",  # path to manage.py inside src
  static-files ? (import ./static-files.nix { # derivation of static files
    inherit pkgs python src settings name manage-py;
  }),
  wsgi ? "${name}.wsgi",  # django wsgi module like `myproject.wsgi`
  processes ? 5,  # number of proccesses for gunicorn server
  threads ? 5,  # number of threads for gunicorn server
  db-name ? name,  # database name
  user ? "django",  # system user for django
  port ? 80,  # port to bind the http server
  allowed-hosts ? "*",  # string of comma separated hosts
  ...
}:
with pkgs;
let
  load-django-env = ''
    export STATIC_ROOT=${static-files}
    export DJANGO_SETTINGS_MODULE=${settings}
    export ALLOWED_HOSTS=${allowed-hosts}
    export DB_NAME=${db-name}
  '';
  load-django-keys = ''
    source /run/${user}/django-keys
  '';
  manage-script-content = ''
    ${load-django-env}
    ${load-django-keys}
    ${python}/bin/python ${manage-py} $@
  '';
  manage = 
    runCommand 
      "manage-${name}-script"
      { propagatedBuildInputs = [ src python ]; }
      ''mkdir -p $out/bin
        bin=$out/bin/manage
        echo -e '${manage-script-content}' > $bin
        chmod +x $bin
      '';
  manage-via-sudo = 
    runCommand 
      "manage-${name}"
      {}
      ''mkdir -p $out/bin
        bin=$out/bin/manage=${name}
        echo -e 'sudo -u ${user} bash ${manage}/bin/manage $@' > $bin
        chmod +x $bin
      '';
  system-config = {
    # manage.py of the project can be called via manage-`projectname`
    environment.systemPackages = [ manage-via-sudo ];

    # create django user
    users.users.${user} = {};

    # The user of django.service might not have permission to access the keys-file.
    # Therefore we copy the keys-file to a place where django has access
    systemd.services.django-keys = {
      description = "Ensure keys are accessible for django";
      wantedBy = [ "django.service" ];
      requiredBy = [ "django.service" ];
      before = [ "django.service" ];
      serviceConfig = { Type = "oneshot"; };
      script = ''
        mkdir -p /run/${user}
        touch /run/${user}/django-keys
        chmod 400 /run/${user}/django-keys
        chown -R ${user} /run/${user}
        cat ${keys-file} > /run/${user}/django-keys
      '';
    };

    # We name the service like the specified user.
    # This allows us to have multiple django projects running in parallel
    systemd.services.${user} = {
      description = "${name} django service";
      wantedBy = [ "multi-user.target" ];
      wants = [ "postgresql.service" ];
      after = [ "network.target" "postgresql.service" ];
      path = [ python src ];
      serviceConfig = {
        LimitNOFILE = "99999";
        LimitNPROC = "99999";
        User = user;
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";  # to be able to bind to low number ports
      };
      script = ''
        ${load-django-env}
        ${load-django-keys}
        ${python}/bin/python ${manage-py} migrate
        ${python}/bin/gunicorn ${wsgi} \
            --pythonpath ${src} \
            -b 0.0.0.0:${toString port} \
            --workers=${toString processes} \
            --threads=${toString threads}
      '';
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ db-name ];
      ensureUsers = [{
        name = "${user}";
        ensurePermissions = {
          "DATABASE ${db-name}" = "ALL PRIVILEGES";
        };
      }];
      package = pkgs.postgresql_11;
    };
  };
in 
{
  inherit 
    manage-via-sudo
    manage
    system-config
    load-django-env
    load-django-keys;
}