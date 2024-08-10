import birdie
import glacier/should
import gleam/bit_array
import gleam/bytes_builder
import http/response
import pprint

pub fn ok_response_test() {
  response.http200()
  |> response.string_body("Hello World!", "text/plain")
  |> bytes_builder.to_bit_array
  |> bit_array.to_string
  |> should.be_ok
  |> birdie.snap("OK response")
}

pub fn notfound_response_test() {
  response.http404()
  |> response.empty_body
  |> bytes_builder.to_bit_array
  |> bit_array.to_string
  |> should.be_ok
  |> birdie.snap("404 Not Found response")
}

pub fn gzipped_response_test() {
  response.http200()
  |> response.gzipped_string_body("Hello World!", "text/plain")
  |> pprint.format
  |> birdie.snap("GZipped response")
}
