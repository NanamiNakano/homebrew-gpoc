class GlobalprotectOpenconnect < Formula
  desc "CLI GlobalProtect VPN client based on OpenConnect"
  homepage "https://github.com/NanamiNakano/homebrew-gpoc"
  url "https://github.com/yuezk/GlobalProtect-openconnect/releases/download/v2.6.4/globalprotect-openconnect-2.6.4.tar.gz"
  sha256 "1f8504871b2dd1cea66abe36c3dbe178bc1917b23aeb915e70d54d50bec1a747"
  license "GPL-3.0-only"
  revision 1

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/NanamiNakano/homebrew-gpoc/releases/download/globalprotect-openconnect-2.6.4"
    sha256 cellar: :any, arm64_tahoe: "935ba51e938bc92d8c15869bcf9616d4114ec43178c37d93f2f7312cd5a2e65c"
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

    gpclient_libexec = libexec/"gpclient"
    inreplace "crates/openconnect/src/vpn_utils.rs" do |s|
    s.gsub! "/usr/libexec/gpclient/hipreport.sh",
            "#{gpclient_libexec}/hipreport.sh"
    s.gsub! "/usr/libexec/gpclient/vpnc-script",
            "#{gpclient_libexec}/vpnc-script"

    ENV["LIBTOOLIZE"] = "glibtoolize" if OS.mac?
    nettle = Formula["nettle@3"]
    ENV.prepend_path "PKG_CONFIG_PATH", nettle.opt_lib/"pkgconfig"
    ENV.append "LDFLAGS", "-Wl,-rpath,#{nettle.opt_lib}"

    system "cargo", "install", *std_cargo_args(path: "apps/gpclient")
    system "cargo", "install", *std_cargo_args(path: "apps/gpauth")

    libexec.install "packaging/files/usr/libexec/gpclient“
  end

  test do
    assert_match "Usage", shell_output("#{bin}/gpclient --help")
    assert_match "Usage", shell_output("#{bin}/gpauth --help")
    assert_path_exists libexec/"gpclient/hipreport.sh"
  end
end
