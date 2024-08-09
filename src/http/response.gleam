import gleam/bytes_builder.{type BytesBuilder}

const http = "HTTP/1.1 "

const crlf = "\r\n"

fn preamble(code: String) -> BytesBuilder {
  bytes_builder.from_string(http <> code <> crlf)
}

pub fn http200() -> BytesBuilder {
  preamble("200 OK")
}

pub fn http404() -> BytesBuilder {
  preamble("404 Not Found")
}

pub fn header(
  previous: BytesBuilder,
  name: String,
  value: String,
) -> BytesBuilder {
  previous
  |> bytes_builder.append_string(name)
  |> bytes_builder.append_string(": ")
  |> bytes_builder.append_string(value)
  |> bytes_builder.append_string(crlf)
}

pub fn string_body(previous: BytesBuilder, body: String) -> BytesBuilder {
  previous
  |> bytes_builder.append_string(crlf)
  |> bytes_builder.append_string(body)
}

pub fn empty_body(previous: BytesBuilder) {
  bytes_builder.append_string(previous, crlf)
}
