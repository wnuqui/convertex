# convertex

A simple Phoenix JSON API application that converts currency. This is a direct port of [konverter](https://github.com/wnuqui/konverter), a Rails application.

## Specifications
- [x] Convert currency to another currency using Google
- [x] Save/cache conversion for the next 60 seconds
- [x] After 60 seconds, convert using Google again

## Sample Usage

Simple `curl` command to convert **USD** to **PHP**.

```bash
# curl command
$ curl -s -X "POST" "http://localhost:4000/api/conversions" \
	-H "Content-Type: application/json" \
	-d "{\"base\":\"USD\",\"amount\":\"1\",\"target\":\"PHP\"}"

# response
# {"data":{"conversion":"1 US dollar = 51.0740 Philippine pesos"}}
```
