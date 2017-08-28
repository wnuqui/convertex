# convertex

A simple Phoenix JSON API application that converts currency. This is a direct port of [konverter](https://github.com/wnuqui/konverter), a Rails application, that do the same.

## Specifications
- [x] Convert currency to another currency using Google
- [ ] Save/cache conversion for the next 60 seconds
- [ ] After 60 seconds, convert using Google again

## Sample Usage

Simple `curl` command to convert **USD** to **PHP**.

```bash
curl -s -X "POST" "http://localhost:4000/api/conversions" \
	-H "Content-Type: application/json" \
	-d "{\"base\":\"USD\",\"amount\":\"1\",\"target\":\"PHP\"}"
```
