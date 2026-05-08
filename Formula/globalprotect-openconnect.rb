class GlobalprotectOpenconnect < Formula
  desc "CLI GlobalProtect VPN client based on OpenConnect"
  homepage "https://github.com/NanamiNakano/homebrew-gpoc"
  url "https://github.com/yuezk/GlobalProtect-openconnect/releases/download/v2.5.3/globalprotect-openconnect-2.5.3.tar.gz"
  sha256 "235017d7ccb85b9aa14b6108a9afeeb871d8bf85ddc66c0c9824d36b5f00c23c"
  license "GPL-3.0-only"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/NanamiNakano/homebrew-gpoc/releases/download/globalprotect-openconnect-2.5.3"
    sha256 cellar: :any, arm64_tahoe: "ac660c5ef02e3b5a960187442c11b2a08f3fcd1355ce6b318e4bee7c44588eaa"
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
  depends_on "nettle"
  depends_on "openssl@3"
  depends_on "p11-kit"

  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  def install
    rm "rust-toolchain.toml", force: true
    system "tar", "-xJf", "vendor.tar.xz" if File.exist?("vendor.tar.xz")

    ENV["LIBTOOLIZE"] = "glibtoolize" if OS.mac?

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
