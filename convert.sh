# convert BASE to TARGET

if [ -z $1 ] || [ -z $2 ]; then
  echo "Usage:"
  echo
  echo "    sh convert.sh USD PHP " "# Convert USD to PHP"
  echo
  echo "Options:"
  echo
  echo "    BASE is required"
  echo "    TARGET is required"
  echo
  exit 0
fi

curl -s -X "POST" "http://localhost:4000/api/conversions" \
	-H "Content-Type: application/json" \
	-d "{\"base\":\"$1\",\"amount\":\"1\",\"target\":\"$2\"}"

echo
