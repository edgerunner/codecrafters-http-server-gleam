import gleam/result
import gleam/uri.{type Uri}
import party.{type Parser, do, try}

pub type Request {
  Request(method: Method, uri: Uri, headers: List(Header), body: String)
}

pub type Method {
  Get
}

pub type Header {
  Header(name: String, value: String)
}

pub type Error {
  InvalidURI
}

pub fn parse(data: String) -> Result(Request, party.ParseError(Error)) {
  party.go(http_request(), data)
}

fn http_request() -> Parser(Request, Error) {
  use method <- do(method())
  use uri <- do(uri())
  use _ <- do(party.string(" HTTP/1.1\r\n"))
  Request(method: method, uri: uri, headers: [], body: "")
  |> party.return
}

fn method() -> Parser(Method, Error) {
  use _ <- do(party.string("GET"))
  use _ <- do(party.whitespace1())
  party.return(Get)
}

fn uri() -> Parser(Uri, Error) {
  use uri_string <- try(
    party.satisfy(fn(ch) { ch != " " }) |> party.many1_concat(),
  )
  uri.parse(uri_string)
  |> result.replace_error(InvalidURI)
}
