import birdie
import glacier/should
import gleam/bit_array
import http/request
import party
import pprint

const sample = "GET /index.html HTTP/1.1\r\nHost: localhost:4221\r\nUser-Agent: curl/7.64.1\r\nAccept: */*\r\n\r\nHello World!"

pub fn parse_sample_test() {
  request.parse(sample)
  |> should.be_ok
  |> pprint.format
  |> birdie.snap("Request sample")
}

pub fn utf8_bytes_test() {
  bit_array.from_string(sample)
  |> request.from_bits
  |> should.be_ok
  |> pprint.format
  |> birdie.snap("UTF8 bytes sample")
}

pub fn non_utf8_test() {
  <<0xFF, 0xFE, 0x41, 0xC3, 0x28>>
  |> request.from_bits
  |> should.be_error
  |> should.equal(party.UserError(party.Position(0, 0), request.NotUTF8))
}

const post_sample = "POST /files/number HTTP/1.1\r
Host: localhost:4221\r
User-Agent: curl/7.64.1\r
Accept: */*\r
Content-Type: application/octet-stream\r
Content-Length: 6\r
\r
123456"

pub fn parse_post_sample_test() {
  request.parse(post_sample)
  |> should.be_ok
  |> pprint.format
  |> birdie.snap("POST Request sample")
}
