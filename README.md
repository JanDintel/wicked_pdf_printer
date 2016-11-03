# wicked_pdf_printer

Run the Wicked PDF Ruby gem in a separate Docker image and connect to to the PDF printer using DRb.

## Problem and solution

We want to deploy Ruby or Rails applications using Docker images based on the popular [Alpine Linux](https://alpinelinux.org/) project. Some of our Rails applications use [Wicked PDF](https://github.com/mileszs/wicked_pdf) to generate PDF files. Wicked PDF uses the shell utility [wkhtmltopdf](http://wkhtmltopdf.org/) to generate these PDF files. However wkhtmltopdf is not stable in combination with Alpine Linux.

We still want to use Wicked PDF, therefore we opted to spin up an extra Docker image which doesn't use Alpine Linux and use Wicked PDF on this image. The extra image runs a [DRb server](https://ruby-doc.org/stdlib-2.3.0/libdoc/drb/rdoc/DRb.html) which provides a RPC interface to Wicked PDF.

## Usage

Build the Docker image for PDF printer server which contains Wicked PDF

`$ docker build -f Dockerfile-server -t wicked_pdf_printer-server:latest .`

Spin up the Docker image and run the `server.rb`

```
$ docker run -it -p 8787:8787 wicked_pdf_printer-server:latest /bin/bash
root@3a55bd373e0d:/app# ruby server.rb
```

Use the `client.rb` on the Docker host to test the PDF printer

`$ ruby client.rb`



