import birdie
import glacier/should
import http/request
import pprint

const sample = "GET /index.html HTTP/1.1\r\nHost: localhost:4221\r\nUser-Agent: curl/7.64.1\r\nAccept: */*\r\n\r\n"

pub fn parse_sample_test() {
  request.parse(sample)
  |> should.be_ok
  |> pprint.format
  |> birdie.snap("Request sample")
}
