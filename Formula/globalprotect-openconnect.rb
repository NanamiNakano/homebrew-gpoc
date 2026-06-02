class GlobalprotectOpenconnect < Formula
  desc "CLI GlobalProtect VPN client based on OpenConnect"
  homepage "https://github.com/NanamiNakano/homebrew-gpoc"
  url "https://github.com/yuezk/GlobalProtect-openconnect/releases/download/v2.5.4/globalprotect-openconnect-2.5.4.tar.gz"
  sha256 "c43a69bc83e45579c3bbe5bbb8181716245e8aa57b4e53f62a1f7514a9596009"
  license "GPL-3.0-only"
  revision 1

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/NanamiNakano/homebrew-gpoc/releases/download/globalprotect-openconnect-2.5.4"
    sha256 cellar: :any, arm64_tahoe: "036c3a55e26a379002979682e3add6beac1256eb886a4f923dec8548468682bb"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  depends_on "gmp"
  depends_on "gnutls"
  depends_on "lz4"
  depends_on :macos
  depends_on "nettle@3"
  depends_on "openssl@3"
  depends_on "p11-kit"

  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  def install
    rm "rust-toolchain.toml", force: true
    system "tar", "-xJf", "vendor.tar.xz" if File.exist?("vendor.tar.xz")

    ENV["LIBTOOLIZE"] = "glibtoolize" if OS.mac?
    nettle = Formula["nettle@3"]
    ENV.prepend_path "PKG_CONFIG_PATH", nettle.opt_lib/"pkgconfig"
    ENV.append "LDFLAGS", "-Wl,-rpath,#{nettle.opt_lib}"

    system "cargo", "install", *std_cargo_args(path: "apps/gpclient")
    system "cargo", "install", *std_cargo_args(path: "apps/gpauth")
    system "cargo", "install", *std_cargo_args(path: "apps/gpservice")

    (libexec/"gpclient").install "packaging/files/usr/libexec/gpclient/hipreport.sh"
  end

  test do
    assert_match "Usage", shell_output("#{bin}/gpclient --help")
    assert_match "Usage", shell_output("#{bin}/gpauth --help")
    assert_path_exists libexec/"gpclient/hipreport.sh"
  end
end
