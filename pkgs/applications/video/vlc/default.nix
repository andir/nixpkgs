{ stdenv, fetchurl, xz, bzip2, perl, xorg, libdvdnav, libbluray
, zlib, a52dec, libmad, faad2, ffmpeg, alsaLib
, libarchive, gettext
, pkgconfig, dbus, fribidi, freefont_ttf, libebml, libmatroska
, libvorbis, libtheora, speex, lua5_1, libgcrypt, libgpgerror, libupnp, libnotify, libsecret, libmodplug
, libcaca, libpulseaudio, flac, schroedinger, libxml2, librsvg
, mpeg2dec, udev, gnutls, avahi, libcddb, libjack2, SDL, SDL_image
, libmtp, unzip, taglib, libkate, libtiger, libv4l, samba, liboggz
, libass, libva, libdvbpsi, libdc1394, libraw1394, libopus
, libvdpau, libsamplerate, live555, fluidsynth, opencv, libssh2, libnfs, libshout
, onlyLibVLC ? false
, qt5
, jackSupport ? false
, fetchpatch
}:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "vlc-${version}";
  version = "3.0.0";

  src = fetchurl {
    url = "http://get.videolan.org/vlc/${version}/${name}.tar.xz";
    sha256 = "1761w3x3568p8y9a78g5h9ddn2wipa5rjs9xrbsqvmahkycqgmb8";
  };

  BUILDCC="${stdenv.cc}/bin/cc";

  buildInputs =
  [  SDL SDL_image a52dec alsaLib avahi bzip2 dbus faad2 ffmpeg flac fluidsynth
    fribidi gnutls libarchive libass libbluray libcaca libcddb libdc1394
    libdvbpsi libdvdnav libdvdnav.libdvdread libebml libgcrypt libgpgerror
    libkate libmad libmatroska libmtp libnfs liboggz libopus libpulseaudio
    libraw1394 librsvg libsamplerate libshout libssh2 libtheora libtiger libupnp libnotify libsecret
    libv4l libva libvdpau libvorbis libxml2 live555 lua5_1 mpeg2dec opencv perl
    samba schroedinger speex taglib udev unzip xorg.libXpm xorg.libXv
    xorg.libXvMC xorg.xcbutilkeysyms xorg.xlibsWrapper xz zlib ]
    ++ optionals (qt5 != null) (with qt5; [ qtbase qtsvg qtx11extras ])
    ++ optional jackSupport libjack2;

  nativeBuildInputs = [ pkgconfig gettext ];

  #  LIVE555_PREFIX = live555;

  preConfigure = ''
    sed -e "s@/bin/echo@echo@g" -i configure
  '';

  configureFlags =
    [ "--enable-alsa"
      "--with-kde-solid=$out/share/apps/solid/actions"
      "--enable-dc1394"
      "--enable-ncurses"
      "--enable-vdpau"
      "--enable-dvdnav"
      "--enable-samplerate"
    ]
    ++ optional onlyLibVLC  "--disable-vlc";

  enableParallelBuilding = true;

  preBuild = ''
    #./config.status share/vlc.appdata.xml.in
    #(cd share; make vlc.appdata.xml)
    #exit 1
  '';

  #  preBuild = ''
  #    substituteInPlace modules/text_renderer/freetype.c --replace \
  #      /usr/share/fonts/truetype/freefont/FreeSerifBold.ttf \
  #      ${freefont_ttf}/share/fonts/truetype/FreeSerifBold.ttf
  #  '';

  meta = with stdenv.lib; {
    description = "Cross-platform media player and streaming server";
    homepage = http://www.videolan.org/vlc/;
    platforms = platforms.linux;
    license = licenses.lgpl21Plus;
  };
}
