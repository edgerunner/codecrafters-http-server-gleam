import birdie
import glacier/should
import gleam/bit_array
import gleam/bytes_builder
import http/response

pub fn ok_response_test() {
  response.http200()
  |> response.header("Content-Type", "text/plain")
  |> response.string_body("Hello World!")
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
