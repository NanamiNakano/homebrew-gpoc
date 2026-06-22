class GlobalprotectOpenconnect < Formula
  desc "CLI GlobalProtect VPN client based on OpenConnect"
  homepage "https://github.com/NanamiNakano/homebrew-gpoc"
  url "https://github.com/yuezk/GlobalProtect-openconnect/releases/download/v2.6.0/globalprotect-openconnect-2.6.0.tar.gz"
  sha256 "a699fa91dfadd71847747bb7d60cb0b356a039632ed6f09eb5d7621165509b81"
  license "GPL-3.0-only"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/NanamiNakano/homebrew-gpoc/releases/download/globalprotect-openconnect-2.6.0"
    sha256 cellar: :any, arm64_tahoe: "3d6defc60ca7e9b7e007cf35a173992f7529e5a648d1f8768f36192ea72d0e89"
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
