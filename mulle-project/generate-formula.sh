#
# For documentation and help see:
#    https://github.com/mulle-nat/mulle-homebrew
#
#

#
# Generate your `def install` `test do` lines here. echo them to stdout.
#
generate_brew_formula_build()
{
#   local project="$1"
#   local name="$2"
#   local version="$3"

  echo <<EOF

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system "false"
  end
EOF
}
