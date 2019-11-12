#!/bin/bash
vpn=/usr/local/bin/vpn
ecfile=~/vpn-exitcode
if [ -f $ecfile ] && [ "$(cat $ecfile)" == 22 ]; then
  rm -f $ecfile
  $vpn -rp
fi
if ! $vpn -np; then
  echo "Enter Password|bash=$vpn param1='-p' terminal=true";
  # echo "Run vpn -p in terminal| bash=/bin/echo param1=test"
  exit 0
fi
CONNECTED=0
if [ -z "$1" ]; then
  if ps -ef|grep 'vpn -[d]' >/dev/null; then
    echo 'Disconnecting... | refresh=true'
  elif ps -ef|grep 'vpn -[c]' >/dev/null; then
    echo 'Connecting... | refresh=true'
  else
    CONNECTED=1
    vpn=$($vpn -g)
    if [[ -z "$vpn" ]]; then
      echo '| image=/9j/4AAQSkZJRgABAQAAkACQAAD/4QCMRXhpZgAATU0AKgAAAAgABQESAAMAAAABAAEAAAEaAAUAAAABAAAASgEbAAUAAAABAAAAUgEoAAMAAAABAAIAAIdpAAQAAAABAAAAWgAAAAAAAACQAAAAAQAAAJAAAAABAAOgAQADAAAAAQABAACgAgAEAAAAAQAAACSgAwAEAAAAAQAAACQAAAAA/+0AOFBob3Rvc2hvcCAzLjAAOEJJTQQEAAAAAAAAOEJJTQQlAAAAAAAQ1B2M2Y8AsgTpgAmY7PhCfv/CABEIACQAJAMBIgACEQEDEQH/xAAfAAABBQEBAQEBAQAAAAAAAAADAgQBBQAGBwgJCgv/xADDEAABAwMCBAMEBgQHBgQIBnMBAgADEQQSIQUxEyIQBkFRMhRhcSMHgSCRQhWhUjOxJGIwFsFy0UOSNIII4VNAJWMXNfCTc6JQRLKD8SZUNmSUdMJg0oSjGHDiJ0U3ZbNVdaSVw4Xy00Z2gONHVma0CQoZGigpKjg5OkhJSldYWVpnaGlqd3h5eoaHiImKkJaXmJmaoKWmp6ipqrC1tre4ubrAxMXGx8jJytDU1dbX2Nna4OTl5ufo6erz9PX29/j5+v/EAB8BAAMBAQEBAQEBAQEAAAAAAAECAAMEBQYHCAkKC//EAMMRAAICAQMDAwIDBQIFAgQEhwEAAhEDEBIhBCAxQRMFMCIyURRABjMjYUIVcVI0gVAkkaFDsRYHYjVT8NElYMFE4XLxF4JjNnAmRVSSJ6LSCAkKGBkaKCkqNzg5OkZHSElKVVZXWFlaZGVmZ2hpanN0dXZ3eHl6gIOEhYaHiImKkJOUlZaXmJmaoKOkpaanqKmqsLKztLW2t7i5usDCw8TFxsfIycrQ09TV1tfY2drg4uPk5ebn6Onq8vP09fb3+Pn6/9sAQwAHBwcHBwcICAgICwsKCwsQDg0NDhAYERIREhEYJBYaFhYaFiQgJh8dHyYgOS0nJy05Qjc0N0JPR0dPZF9kg4Ow/9sAQwEHBwcHBwcICAgICwsKCwsQDg0NDhAYERIREhEYJBYaFhYaFiQgJh8dHyYgOS0nJy05Qjc0N0JPR0dPZF9kg4Ow/9oADAMBAAIRAxEAAAHv0t+dzxubHkOnZXOmG6K8jxCpxqrR518lpG3N3TtFTG1bbV//2gAIAQEAAQUC7G6jSvj2lkESVXEymgyxpjkEiXcRmUCJCUSIntxaSyj7l5zFi1hMMf3v/9oACAEDEQE/AcmaGPg8n8g4cpne7z5Ar002R3GVclGEjP8AZKQjEf7wO3//2gAIAQIRAT8BlMR48lju8y02i79X7Y4bNWfA/wB89v8A/9oACAEBAAY/Au2OvepZpoB6PnJAKfNhQ8+yAP2nhTTzawNY1PlpRUFXH0+4mJCSa6l0VxJr9/8A/8QAMxABAAMAAgICAgIDAQEAAAILAREAITFBUWFxgZGhscHw0RDh8SAwQFBgcICQoLDA0OD/2gAIAQEAAT8hs1oxxkhO0QCcP/OW2wHlszSCWPB7btdIDzz+rxX/AKf864NPgisBoR7fNyeELybm+GxcIVU8uf8AsWYPWBkHG19BsRv/AOP/2gAMAwEAAhEDEQAAEG8dDwHBHPP/xAAzEQEBAQADAAECBQUBAQABAQkBABEhMRBBUWEgcfCRgaGx0cHh8TBAUGBwgJCgsMDQ4P/aAAgBAxEBPxBDkw2GQsR1HLpH5PAOUDFfp1FTsJ2G8oX8P//aAAgBAhEBPxBY5J8HccuHL0HX8+APPL5hIbbt/q/D/9oACAEBAAE/EKkzuziBKN8gDWO4K5UhJkfp/wCRrUwXKb9UVVJ8B2m0lMrUIQZyfkVu2Ph5RiPsf+LWBI3YifdK+vk5mQq82fJWLIYPbpnivRXGQYdMMJ3/AIkkVZ7oGYHycJUBLvPVbuXFQMAJ7gP/AMf/2Q=='
    else
      echo "$vpn | color=green image=iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAACXBIWXMAAA7EAAAOxAGVKw4bAAABWWlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNS40LjAiPgogICA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogICAgICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgICAgICAgICB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyI+CiAgICAgICAgIDx0aWZmOk9yaWVudGF0aW9uPjE8L3RpZmY6T3JpZW50YXRpb24+CiAgICAgIDwvcmRmOkRlc2NyaXB0aW9uPgogICA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgpMwidZAAADIklEQVQ4Ea2T7WtbVRjAf3m5ucnavLWNa5pmyCqRjZGZjFmGxrQZA/dNixP84MR/YIIw/OIf4SdB0Q6H+6pgJEPwrVvXrNS6ih1LG6FF0y6JaS5JuyQ3yU2991xJLfabHjgvzznP8zvPec7zWPb1xv/Q7EcxqtUqS0tL5PO/0WyqNNt7dKwqsdPnSL6YZHh4+F9mln961Gq1WFxc5OGjHMnkFCfGx+jaOpSebPFYKZFf36S8tsNkNE4ikcDpdPaBfZAByWQyeDwjTE+9QG13j3KtyELhO+zSMRLhFKPeIDbJytz8PH8Wt5mZebUP64Oy2fuUywpPnw2wvHmXarNKs9tD1awcY4RYME40HEF2yEiyzEJ2AdluIZVKCa9EjBRF4Yc73zM02eXH5Qe0uhb2tUFs+PTZTaGl4NteZf6rbzA8N9rExAQd/aJYLIbf70eA1tbXuNe4xVPFIbT2ACc9cc6MPM/CxkP+UHaZto+TTqe5fTsjIMYwlbrE66/NsLLyC9PTUybowa8/UXBsINf9XHn2Lc6HXmJQdpHbqjFXWqF6/wtufnaDd66/r//kOi6HxK2bN7j27ntYLBYBshr07dIWLvk4V565xoXwRbDuo/ZaxEOn6bS9SJJEoVBgI5/jUeAVntQVIZd3FGr1moFAgCSbzJunrjMZTuoBbqD1NNSuxqnQKFfPX2BoyId70IXdbkNtCzshtztdXdfMZwGaOBHhjHuSrtXU6umHmmbCvp39gGBwTFjv7FSIlj43SX+Pd+fuiJX4/tXVVZaW9aBdvESz0Tik+PbVN8hm72Gp/Ay/p2Hza/O8o8sJGDk7TKVSMZ8WCoXYrVVF4JwuFw6Ho98PUY8QZJdb7IqnGXlw+fLLZNJfEh4/LmrJ6/Xh9XoplkpHmB9s2STHAchYhcNhzsWf45OPP8Ip6S779Xz2D+BxmzcemB5etdWm2OhXv1GA0WgUn8/H7OynuHVAPB4XPyU0tQ9hMK/fuGWSZHOyWm2HQYZkwCKRCIFAgGKxSC6Xo1arExwLM+D2YMSj3R6l21Hp9Xw09uq6lSpA/aIV0n8Y/gLIMDyWVHE1GAAAAABJRU5ErkJggg=="
    fi
  fi
else
  if [[ "$1" = "disconnect" ]]; then
    $vpn -d &
    echo 'Disconnecting...| refresh=true'
  else
    if ! $vpn -np ; then
      # echo "|bash=$(command -v vpn) param1='-p' terminal=true";
      echo "Run vpn -p in terminal| bash=/bin/echo param1=test"
      exit 0
    fi
    $vpn -c "$1" "$2" || echo $? > $ecfile &
    echo "Connecting ($1)...| refresh=true"
  fi
fi
echo "---"
[[ "$CONNECTED" -eq 1 ]] && echo "Disconnect| color=red bash='$0' param1=disconnect terminal=false refresh=true";
echo "Connect | color=green"
echo "--aloha-west | bash='$0' param1=aloha-west terminal=false refresh=true"
echo "--internal.tomax.com | bash='$0' param1=internal.tomax.com terminal=false refresh=true"
echo "--slc.tomax.com"
echo "----Retail.net | bash='$0' param1=slc.tomax.com param2=0 terminal=false refresh=true"
echo "----Store | bash='$0' param1=slc.tomax.com param2=1 terminal=false refresh=true"
