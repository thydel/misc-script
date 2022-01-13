# With a little help from my friends

See [wordle.mk](wordle.mk)

# 2022-01-13

```console
thy@tde-ws:~/usr/misc-script$ wordle.mk
mkdir -p tmp/wordle
< /usr/share/dict/american-english sed -e "s/'s$//" | grep '^.....$' | tr '[:upper:]' '[:lower:]' | sort -u > tmp/wordle/five-letters
< tmp/wordle/five-letters grep -v '\(.\).*\1' > tmp/wordle/five-unique-letters
thy@tde-ws:~/usr/misc-script$ wordle.mk first
< tmp/wordle/five-unique-letters shuf -n1
amber
thy@tde-ws:~/usr/misc-script$ wordle.mk look g=a.be. e=rm
< tmp/wordle/five-letters grep a.be. | grep -v [rm]
abbey
albee
```
