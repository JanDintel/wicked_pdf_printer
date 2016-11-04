# frozen_string_literal: true
require 'drb'
require 'bundler'
Bundler.require(:default, :development, :server)

# Security notice!
#
# Normally you would run the DRb server with $SAFE=1,
# to update the safe level. This prevents untrusted calls
# to the system, e.g. disables eval() and friends.
#
# However since WickedPdf uses Open3 to pass the
# body to wkhtml2pdf, we can't set the safe level. Otherwise
# the client will fail with DRb::DRbConnError.
#
# Instead of using the safe level we try to mitigate some
# of the security risks by undefining 'dangerous' methods.
#
# Methods __send__() and send() can't be undefined.
#
# More information:
# https://ruby-doc.org/stdlib-2.3.0/libdoc/drb/rdoc/DRb.html#module-DRb-label-Security
# http://blog.recurity-labs.com/archives/2011/05/12/druby_for_penetration_testers/

# Kernel methods:
undef :`
undef :eval
undef :exec
undef :syscall
undef :system
# Object methods
undef :untaint
undef :untrust
# BasicObject methods:
undef :instance_eval
undef :instance_exec

# DRB Server URI
if ENV['DOCKER']
  SERVER_URI = 'druby://0.0.0.0:8787'
else
  SERVER_URI = 'druby://localhost:8787'
end

# WickedPDF Global Configuration
WickedPdf.config = {
  # To learn more, check out the README:
  # https://github.com/mileszs/wicked_pdf/blob/master/README.md
  #
  # Path to the wkhtmltopdf executable: This usually isn't needed if using
  # one of the wkhtmltopdf-binary family of gems.
  #
  # $ brew cask install wkhtmltopdf
  # exe_path: '/usr/local/bin/wkhtmltopdf',
  #
  # $ apt-get install -y wkhtmltopdf
  # exe_path: '/usr/bin/wkhtmltopdf',
  #
  # gem 'wkhtmltopdf-binary'
  exe_path: Gem.bin_path('wkhtmltopdf-binary', 'wkhtmltopdf')
}

class PDFPrinterServer
  def print(body, options = {})
    $stdout.puts('Generating PDF...')
    tainted_body = body.taint
    pdf_blob     = WickedPdf.new.pdf_from_string(tainted_body, options)
    $stdout.puts('Generated PDF!')
    pdf_blob
  end
end

pdf_printer_server = PDFPrinterServer.new
$stdout.puts('Started server...')
DRb.start_service(SERVER_URI, pdf_printer_server, verbose: true)
DRb.thread.join # Wait for the drb server thread to finish before exiting.
$stdout.puts('Stopped server!')
