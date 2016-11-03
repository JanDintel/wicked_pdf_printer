require 'drb'
require 'bundler'
Bundler.require(:default, :development, :server)

# TODO: Ensure security!

# Disable eval() and friends
# $SAFE = 1

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
  def print(body)
    WickedPdf.new.pdf_from_string(body, page_size: 'A4')
  end
end

pdf_printer_server = PDFPrinterServer.new

$stdout.puts('Started server...')
DRb.start_service(SERVER_URI, pdf_printer_server)
DRb.thread.join # Wait for the drb server thread to finish before exiting.
$stdout.puts('Stopped server!')
