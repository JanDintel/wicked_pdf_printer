require 'drb'
require 'bundler'
Bundler.require(:default, :development)

# DRB Server URI
if ENV['DOCKER_HOST']
  SERVER_URI = "druby://#{URI.parse(ENV['DOCKER_HOST']).host}:8787"
else
  SERVER_URI = 'druby://localhost:8787'
end

def write_file(path, blob)
  File.open(path, 'wb') { |file| file.write(blob) }
end

def save(filename, blob)
  save_path = File.join('tmp', filename)
  write_file(save_path, blob)
end

def save_and_open(filename, blob)
  save_path = File.join('tmp', filename)
  write_file(save_path, blob)
  Launchy.open(save_path.to_s)
end

pdf_printer_server = DRbObject.new_with_uri(SERVER_URI)

body = '<h1>Hello world</h1>'

pdf_document = pdf_printer_server.print(body)

if ENV['DOCKER']
  save("#{Time.now.to_i}.pdf", pdf_document)
else
  save_and_open("#{Time.now.to_i}.pdf", pdf_document)
end
