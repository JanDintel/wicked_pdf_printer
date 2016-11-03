require 'bundler'
Bundler.require(:default, :development, :server)

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

def save_file(path, blob)
  File.open(path, 'wb') { |file| file.write(blob) }
end

def save_and_open(filename, blob)
  save_path = File.join('tmp', filename)
  save_file(save_path, blob)
  Launchy.open(save_path.to_s)
end

$SAFE = 1   # disable eval() and friends

body   = '<h1>Hello world</h1>'
header = '<p>Header</p>'
footer = '<p>footer</p>'

# pdf_document = WickedPdf.new.pdf_from_string(body, page_size: 'A4', header: { content: header }, footer: { content: footer }, margin: { top: '35mm', bottom: '35mm' })
pdf_document = WickedPdf.new.pdf_from_string(body, page_size: 'A4')

save_and_open("#{Time.now.to_i}.pdf", pdf_document)
