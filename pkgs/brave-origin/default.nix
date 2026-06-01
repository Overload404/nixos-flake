{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  dpkg,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  adwaita-icon-theme,
  gsettings-desktop-schemas,
  gtk3,
  gtk4,
  qt6,
  libx11,
  libxscrnsaver,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxrandr,
  libxrender,
  libxtst,
  libdrm,
  libkrb5,
  libuuid,
  libxkbcommon,
  libxshmfence,
  libgbm,
  nspr,
  nss,
  pango,
  pipewire,
  snappy,
  udev,
  wayland,
  xdg-utils,
  coreutils,
  libxcb,
  zlib,

  # Optional: PulseAudio for audio device support
  libpulseaudio,
  pulseSupport ? stdenv.hostPlatform.isLinux,

  # GPU / OpenGL
  libGL,

  # Optional: VA-API hardware video acceleration
  libva,
  libvaSupport ? stdenv.hostPlatform.isLinux,
  enableVideoAcceleration ? libvaSupport,

  # Optional: Vulkan support (disabled by default - conflicts with VA-API)
  vulkanSupport ? false,
  addDriverRunpath,
  enableVulkan ? vulkanSupport,
}:

let
  inherit (lib)
    optional
    optionals
    makeLibraryPath
    makeSearchPathOutput
    makeBinPath
    optionalString
    strings
    escapeShellArg
    ;

  pname = "brave-origin";
  version = "1.92.111";

  # ---------------------------------------------------------------------------
  # Package paths inside the .deb
  # ---------------------------------------------------------------------------
  # The upstream .deb installs into /opt/brave.com/brave-origin-beta/
  # with the wrapper script named brave-origin-beta.
  # We expose it as $out/bin/brave-origin and $out/bin/brave-origin-beta.
  packagePath = "brave-origin-beta";
  appName = "Brave Origin Beta";

  # ---------------------------------------------------------------------------
  # Source archives per platform
  # ---------------------------------------------------------------------------
  # Brave Origin Beta currently only provides amd64 Linux debs.
  # For arm64-linux, use the "brave-origin" (non-beta) channel:
  #   https://github.com/brave/brave-browser/releases/download/v1.91.165/brave-origin_1.91.165_arm64.deb
  #   (with corresponding packagePath = "brave-origin")
  #
  # To update: run `nix-prefetch-url --type sha256 <url>` to get the hash,
  # or use `lib.fakeHash` and let the build fail to reveal the correct hash.
  allArchives = {
    x86_64-linux = {
      url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-origin-beta_${version}_amd64.deb";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
  };

  archive =
    if builtins.hasAttr stdenv.hostPlatform.system allArchives then
      allArchives.${stdenv.hostPlatform.system}
    else
      throw "${pname} is not yet available for ${stdenv.hostPlatform.system}";

  # ---------------------------------------------------------------------------
  # Runtime library dependencies (Chromium-like)
  # ---------------------------------------------------------------------------
  deps = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    gtk4
    libdrm
    libx11
    libGL
    libxkbcommon
    libxscrnsaver
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxshmfence
    libxtst
    libuuid
    libgbm
    nspr
    nss
    pango
    pipewire
    udev
    wayland
    libxcb
    zlib
    snappy
    libkrb5
    qt6.qtbase
  ]
  ++ optional pulseSupport libpulseaudio
  ++ optional libvaSupport libva;

  rpath = makeLibraryPath deps + ":" + makeSearchPathOutput "lib" "lib64" deps;
  binpath = makeBinPath deps;

  # ---------------------------------------------------------------------------
  # Chromium feature flags
  # ---------------------------------------------------------------------------
  enableFeatures =
    optionals enableVideoAcceleration [
      "AcceleratedVideoDecodeLinuxGL"
      "AcceleratedVideoEncoder"
    ]
    ++ optional enableVulkan "Vulkan";

  disableFeatures =
    # Disable the "your browser is out of date" nag
    [ "OutdatedBuildDetector" ]
    # Required for VA-API to work correctly:
    # https://github.com/brave/brave-browser/issues/20935
    ++ optionals enableVideoAcceleration [ "UseChromeOSDirectVideoDecoder" ];

in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    inherit (archive) url;
    hash = archive.hash;
  };

  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true;

  nativeBuildInputs = [
    dpkg
    # Use buildPackages.wrapGAppsHook3 with makeShellWrapper to avoid
    # splicing issues (nixpkgs#132651).
    (buildPackages.wrapGAppsHook3.override {
      makeWrapper = buildPackages.makeShellWrapper;
    })
  ];

  buildInputs = [
    # Needed for GSETTINGS_SCHEMAS_PATH
    glib
    gsettings-desktop-schemas
    gtk3
    gtk4

    # Needed for XDG_ICON_DIRS
    adwaita-icon-theme
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out $out/bin

    # Extract .deb contents
    cp -R usr/share $out
    cp -R opt/ $out/opt

    export BINARYWRAPPER=$out/opt/brave.com/${packagePath}/${packagePath}

    # Fix path to bash in the upstream wrapper script
    substituteInPlace $BINARYWRAPPER \
      --replace-fail /bin/bash ${stdenv.shell} \
      --replace-fail 'CHROME_WRAPPER' 'WRAPPER'

    # Create convenience symlinks so users can run either name
    ln -sf $BINARYWRAPPER $out/bin/brave-origin
    ln -sf $BINARYWRAPPER $out/bin/brave-origin-beta

    # Patch ELF interpreter and set rpath on the main binaries
    for exe in $out/opt/brave.com/${packagePath}/{brave,chrome_crashpad_handler}; do
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "${rpath}" $exe
    done

    # Fix paths in .desktop files
    substituteInPlace $out/share/applications/brave-origin-beta.desktop \
      --replace-fail /usr/bin/brave-origin-beta $out/bin/brave-origin
    substituteInPlace $out/share/applications/com.brave.Origin.beta.desktop \
      --replace-fail /usr/bin/brave-origin-beta $out/bin/brave-origin

    # Fix GNOME control center default-apps XML (if present)
    if [ -f $out/share/gnome-control-center/default-apps/brave-origin-beta.xml ]; then
      substituteInPlace $out/share/gnome-control-center/default-apps/brave-origin-beta.xml \
        --replace-fail /opt/brave.com $out/opt/brave.com
    fi

    # Fix the default-app-block file
    if [ -f $out/opt/brave.com/${packagePath}/default-app-block ]; then
      substituteInPlace $out/opt/brave.com/${packagePath}/default-app-block \
        --replace-fail /opt/brave.com $out/opt/brave.com
    fi

    # Create icon symlinks for hicolor theme
    icon_sizes=("16" "24" "32" "48" "64" "128" "256")

    for icon in ''${icon_sizes[*]}; do
      mkdir -p $out/share/icons/hicolor/$icon\x$icon/apps
      ln -sf $out/opt/brave.com/${packagePath}/product_logo_''${icon}_beta.png \
        $out/share/icons/hicolor/$icon\x$icon/apps/brave-origin-beta.png
    done

    # Replace upstream xdg-utils wrappers with symlinks to our xdg-utils
    ln -sf ${xdg-utils}/bin/xdg-settings $out/opt/brave.com/${packagePath}/xdg-settings
    ln -sf ${xdg-utils}/bin/xdg-mime $out/opt/brave.com/${packagePath}/xdg-mime

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : ${rpath}
      --prefix PATH : ${binpath}
      --suffix PATH : ${
        lib.makeBinPath [
          xdg-utils
          coreutils
        ]
      }
      --set CHROME_WRAPPER ${pname}
      ${
        optionalString (enableFeatures != [ ]) ''
          --add-flags "--enable-features=${strings.concatStringsSep "," enableFeatures}\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+,WaylandWindowDecorations --enable-wayland-ime=true}}"
        ''
      }
      ${
        optionalString (disableFeatures != [ ]) ''
          --add-flags "--disable-features=${strings.concatStringsSep "," disableFeatures}"
        ''
      }
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto}}"
      ${
        optionalString vulkanSupport ''
          --prefix XDG_DATA_DIRS : "${addDriverRunpath.driverLink}/share"
        ''
      }
      --add-flags ${escapeShellArg ""}
    )
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    # Verify the main binary runs and reports its version
    $out/opt/brave.com/${packagePath}/brave --version
  '';

  meta = with lib; {
    homepage = "https://brave.com/origin/download-beta/";
    description = "Privacy-oriented browser for Desktop and Laptop computers (Brave Origin Beta)";
    changelog =
      "https://github.com/brave/brave-browser/blob/master/CHANGELOG_DESKTOP_ORIGIN.md#"
      + lib.replaceStrings [ "." ] [ "" ] version;
    longDescription = ''
      Brave Origin is a minimalist version of Brave browser that blocks ads
      and trackers. This derivation fetches the official binary release from
      Brave's GitHub releases.

      Two binaries are installed:
        - brave-origin
        - brave-origin-beta
    '';
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ ];
    platforms = builtins.attrNames allArchives;
    mainProgram = "brave-origin";
  };
}
